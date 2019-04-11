require 'pp'

require_relative 'lexer'
require_relative 'ast'
require_relative 'indent'
require_relative 'pretty_printer'

module Crokus

  class Parser

    attr_accessor :tokens,:str
    include Indent

    def initialize
      @ppr=PrettyPrinter.new
      @verbose=false
      #@verbose=true
    end

    def acceptIt
      say showNext.kind.to_s+" "+showNext.val
      tokens.shift
    end

    def maybe kind
      return acceptIt if showNext.is_a? kind
    end

    def expect kind
      if ((actual=tokens.shift).kind)!=kind
        puts "ERROR :"
        show_line(actual.pos)
        raise "expecting '#{kind}'. Received '#{actual.val}' around #{actual.pos}"
      end
      say actual.kind.to_s+" "+actual.val
      return actual
    end

    def showNext(n=1)
      tokens[n-1] if tokens.any?
    end

    def lookahead(n=2)
      tokens[n] if tokens.any?
    end

    def show_line pos
      l,c=*pos
      show_lines(str,l-2)
      line=str.split(/\n/)[l-1]
      pointer="-"*(5+c)+ "^"
      puts "#{l.to_s.ljust(5)}|#{line}"
      puts pointer
    end
    #--------------------------------------------------
    def dbg_print_next n
      p tokens[0..n-1].collect{|tok| tok.inspect}
    end

    def dbg_print node
      puts "debug ast node".center(60,'-')
      puts node.accept(@ppr)
      puts "-"*60
    end
    #............ parsing methods ...........
    def parse str
      begin
        @str=str
        @tokens=Lexer.new.tokenize(str)
        @tokens=remove_comments()
        warnings=@tokens.select{|tok| tok.is_a? :lexer_warning}
        show_lexer_warnings(warnings)
        @tokens=@tokens.select{|tok| !tok.is_a? [:newline]}
        ast=design_unit()
      rescue Exception => e
        puts "PARSING ERROR : #{e}"
        puts "in C source at line/col #{showNext.pos}"
        puts e.backtrace
        abort
      end
    end

    def show_lexer_warnings warnings
      warnings.each do |warn|
        puts "lexer warning : #{warn.val} at #{warn.pos}"
      end
    end

    def remove_comments
      ret=[]
      in_comment=false
      tokens.each do |tok|
        case tok.kind
        when :comment
        when :lcomment
          in_comment=true
        when :rcomment
          in_comment=false
        else
          ret << tok unless in_comment
        end
      end
      ret
    end

    def design_unit
      indent "designUnit"
      du=DesignUnit.new
      while tokens.any?
        case showNext.kind
        when :sharp
          case showNext(2).val
          when "include"
            du << include()
          when "define"
            du << define()
          end
        else
          du << declaration
          maybe :semicolon if tokens.any?
        end
      end
      dedent
      return du
    end

    def include
      indent "include"
      expect :sharp
      expect :ident #include
      case showNext.kind
      when :lt
        acceptIt
        id1=expect :ident
        expect :dot
        id2=expect :ident
        expect :gt
        name=Token.new [:ident,id1.val+"."+id2.val,id1.pos]
        env=:env
      when :string_lit
        name=acceptIt
        env=:local
      end
      dedent
      return Include.new(name,env)
    end

    def define
      indent "define"
      expect :sharp
      expect :ident #define
      name=expect :ident
      e=expression()
      dedent
      return Define.new(name,e)
    end

    def struct
      indent "struct"
      expect :struct
      name=nil
      if showNext.is_a? :ident
        name=acceptIt
      end
      ret=Struct.new(name)
      if showNext.is_a? :lbrace
        acceptIt
        while !showNext.is_a? :rbrace
          ret.decls << declaration()
        end
        ret.decls.flatten!
        expect :rbrace
      end
      dedent
      return ret
    end

    def typedef
      indent "typedef"
      expect :typedef
      type=type()
      id=expect(:ident)
      dedent
      return Typedef.new(type,id)
    end

    def function_decl name,type_
      indent "function"
      args=function_formal_args()
      case showNext.kind
      when :semicolon
        acceptIt
        ret =FunctionProto.new(name,type_,args)
      else
        body=function_body()
        ret= Function.new(name,type_,args,body)
      end
      dedent
      return ret
    end

    def function_formal_args
      indent "function_formal_args"
      args=[]
      expect :lparen
      while !showNext.is_a? :rparen
        args << func_formal_arg()
        if !showNext.is_a? :rparen
          expect :comma
        end
      end
      expect :rparen
      dedent
      return args
    end

    def func_formal_arg
      indent "function_arg"
      @current_type=type()
      declarator
      arrayed?
      parenthesized?
      dedent
      #return FormalArg.new(name,type)
    end

    def function_body
      indent "function_body"
      body=Body.new
      expect :lbrace
      while showNext.kind!=:rbrace
        body << statement()
      end
      expect :rbrace
      dedent
      return body
    end

    def statement(arg=nil)
      indent "statement ...#{showNext.kind} #{showNext.pos.first}"
      case showNext.kind
      when :lbrace
        ret=parse_body()
      when :unsigned,:signed,:int,:short,:float,:double,:long,:char,:void
        ret=declaration()
      when :struct
        ret=declaration()
      when :if
        ret=parse_if()
      when :while
        ret=parse_while()
      when :for
        ret=parse_for()
      when :switch
        ret=switch()
      when :return
        ret=parse_return
      when :break
        acceptIt
        ret=Break.new
      when :do
        ret=do_while()
      when :goto
        ret=parse_goto()
      when :ident
        case showNext(2).kind
        when :ident
          declaration
        when :colon
          parse_label
          statement
        else
          expression_statement
        end
      when :const,:volatile
        declaration
      when :semicolon
        expression_statement
      else
        show_line(showNext.pos)
        raise "unknown statement start at #{showNext.pos} .Got #{showNext.kind} #{showNext.val}"
      end
      dedent
      return ret
    end

    def parse_label
      expect :ident
      expect :colon
    end

    def parse_goto
      indent "goto"
      expect :goto #label
      id=expect(:ident)
      dedent
      Goto.new(id)
    end

    def do_while
      indent "do_while"
      expect :do
      body=statement()
      expect :while
      e=expression
      dedent
      DoWhile.new(e,body)
    end

    def switch
      indent "switch"
      expect :switch
      expect :lparen
      e=expression
      ret=Switch.new(e,cases=[])
      expect :rparen
      expect :lbrace
      while showNext.is_a? :case
        expect :case
        case_e=expression
        case_body=Body.new
        expect :colon
        while showNext.kind!=:rbrace and showNext.kind!=:case and showNext.kind!=:default
          case_body << statement()
        end
        cases << Case.new(case_e,case_body)
      end
      if showNext.is_a? :default
        acceptIt
        expect :colon
        while showNext.kind!=:rbrace
          statement()
        end
      end
      expect :rbrace
      dedent
      return ret
    end

    def parse_return
      indent "parse_return"
      expect :return
      if showNext.is_a? :semicolon
      else
        e=expression
      end
      dedent
      Return.new(e)
    end

    # int a
    # int * a
    # int a=1,b=2;
    # int a[]
    # int* f()
    # struct name *ptr;
    # paire_t paire = {1,2};
    # int a,b[10],*c
    #------------------------------
    # TYPE ident
    # ident ident

    def declaration
      @current_type=type()
      declarator
      arrayed?
      parenthesized?
      initialization?
      while tokens.any? and showNext.is_a? :comma
        acceptIt
        pointed?
        declarator
        arrayed?
        initialization?
      end
      if tokens.any?
        maybe :semicolon
      end
    end

    def declarator
      if showNext.is_a? :ident
        @current_ident=acceptIt
      end
    end

    def pointed?
      return if tokens.empty?
      while showNext.is_a? :mul
        acceptIt
      end
    end

    def arrayed?
      return if tokens.empty?
      while showNext.is_a? :lbrack
        acceptIt
        if showNext.is_a? :rbrack
          acceptIt
        else
          expression
          expect :rbrack
        end
      end
    end

    def initialization?
      return if tokens.empty?
      if showNext.is_a? :assign
        expect :assign
        expression
      end
    end

    def parenthesized?
      return if tokens.empty?
      if showNext.is_a? :lparen
        function_decl(@current_ident,@current_type)
      end
    end

    def func_call as_procedure=false
      indent "func_call"
      name=expect(:ident)
      expect :lparen
      args=[]
      while !showNext.is_a? :rparen
        args << expression()
        if showNext.is_a? :comma
          acceptIt
        end
      end
      expect :rparen
      dedent
      FunCall.new(name,args,as_procedure)
    end

    def type
      indent "type"
      type_qualifier?
      case showNext.kind
      when :signed,:unsigned
        acceptIt
      when :ident,:char,:int,:short,:long,:float,:double,:void
        acceptIt
      when :struct
        struct()
      when :typedef
        typedef()
      else
        raise "Parsing ERROR in type declaration: '#{showNext}'"
      end
      while showNext.is_a? [:mul,:lparen]
        case showNext.kind
        when :mul
          acceptIt
        when :lparen
          acceptIt
          if showNext.is_a? :rparen
            acceptIt
          else
            expression
            expect :rparen
          end
        end
      end
      dedent
    end

    def type_qualifier?
      while showNext.is_a? STARTERS_TYPE_QUALIFIER
        case showNext.kind
        when :volatile
          acceptIt
        when :const
          acceptIt
        end
      end
    end

    def parse_if
      indent "parse_if"
      expect :if
      if showNext.is_a? :lparen # helps wrt casting.
        acceptIt
        lparen=true
      end
      cond=expression()
      expect :rparen if lparen
      body=statement()
      if showNext.is_a? :else
        else_=parse_else()
      end
      dedent
      return If.new(cond,body,else_)
    end

    def parse_else
      indent "parse else"
      expect :else
      ret=Else.new
      ret.body=statement()
      dedent
      return ret
    end

    def parse_while
      indent "parse_while"
      expect :while
      cond=expression()
      body=[]
      body << statement()
      dedent
      return While.new(cond,body)
    end

    def parse_for
      indent "parse_for"
      forloop=For.new
      expect :for
      expect :lparen
      forloop.init=expression_statement()
      forloop.cond=expression_statement()
      forloop.increment=expression()
      expect :rparen
      forloop.body=statement()
      dedent
      forloop
    end

    def parseLoopInit
      indent "parseLoopInit"
      ret=statement()
      dedent
      return [ret] # because for (int a,b=0;i<10;i++) is also possible.
      # then parser returns an array of Decl
    end

    def parseLoopCond
      indent "parseLoopCond"
      e=expression()
      dedent
      return e
    end

    def parseLoopEnd
      indent "parseLoopEnd"
      s=statement()
      dedent
      return s
    end

    def accu
      indent "accu"
      #expect(:ident)
      lhs=expression
      case showNext.kind
      when :addadd,:subsub
        tok=acceptIt
      when :addeq,:subeq
        tok=acceptIt
        e=expression
      else
        show_line(showNext.pos)
        raise "unknown accumulator at #{showNext.pos}"
      end
      dedent
      Accu.new(lhs,tok,e)
    end

    def parse_body
      body=Body.new
      expect :lbrace
      while !showNext.is_a? :rbrace
        body << statement()
      end
      expect :rbrace
      return body
    end

    def expression_statement
      if showNext.is_a? :semicolon
        acceptIt
      else
        expression
        expect :semicolon
      end
    end
    #===============================================================
    def debug
      puts " "*@indentation+@tokens[0..4].map{|t| "'#{t.val}'"}.join(" ")
    end
    #===============================================================
    def expression
      indent "expression : #{showNext}"
      assign()
      while showNext.is_a? :comma
        acceptIt
        assign()
      end
      dedent
    end

    STARTERS_ARRAY_OR_STRUCT_INIT=[:lbrace]
    STARTERS_PRIMARY=[:ident,:integer_lit,:float_lit,:string_lit,:char_lit,:lparen]+STARTERS_ARRAY_OR_STRUCT_INIT
    UNARY_OP=[:and,:mul,:add,:sub,:tilde,:not]
    STARTERS_UNARY=[:inc_op,:dec_op,:sizeof]+STARTERS_PRIMARY+UNARY_OP
    ASSIGN_OP=[:assign,:add_assign,:mul_assign,:div_assign,:mod_assign,:xor_assign]

    def assign
      indent "assign : #{showNext}"
      cond_expr
      if showNext.is_a? ASSIGN_OP
        acceptIt
        assign
      end
      dedent
    end

    def cond_expr
      indent "cond_expr : #{showNext}"
      logor
      while showNext.is_a? :qmark
        acceptIt
        expect :colon
        cond_expr
      end
      dedent
    end

    def logor
      indent "logor : #{showNext}"
      logand
      while showNext.is_a? :oror
        acceptIt
        logand
      end
      dedent
    end

    def logand
      indent "logand : #{showNext}"
      inclor
      while showNext.is_a? :andand
        acceptIt
        inclor
      end
      dedent
    end

    def inclor
      indent "inclor : #{showNext}"
      exclor
      while showNext.is_a? :or
        acceptIt
        exclor
      end
      dedent
    end

    def exclor
      indent "exclor : #{showNext}"
      andexp
      while showNext.is_a? :xor
        acceptIt
        andexp
      end
      dedent
    end

    def andexp
      indent "andexp : #{showNext}"
      eqexp
      while showNext.is_a? :and
        acceptIt
        eqexp
      end
      dedent
    end

    def eqexp
      indent "eqexp : #{showNext}"
      relexp
      while showNext.is_a? [:eq,:neq]
        acceptIt
        relexp
      end
      dedent
    end

    def relexp
      indent "relexp : #{showNext}"
      shiftexp
      while showNext.is_a? [:lte,:lt,:gte,:gt ]
        acceptIt
        shiftexp
      end
      dedent
    end

    def shiftexp
      indent "shiftexp : #{showNext}"
      additive
      while showNext.is_a? [:shift_l,:shift_r]
        acceptIt
        additive
      end
      dedent
    end

    def additive
      indent "addititve : #{showNext}"
      multitive
      while showNext.is_a? [:add,:sub]
        acceptIt
        multitive
      end
      dedent
    end

    def multitive
      indent "multitive : #{showNext}"
      castexp
      while showNext.is_a? [:mul,:div,:mod]
        acceptIt
        castexp
      end
      dedent
    end

    def castexp
      indent "castexpr : #{showNext}"
      case showNext.kind
      when :lparen # parenth expr OR casting !
        res=is_casting?
        puts "casting? : #{res}" if @verbose
        if res
          casting
        else
          parenthesized
        end
      else
        unary
      end
      dedent
    end

    def is_casting?
      i=0
      tok=DUMMY
      while tok.kind!=:rparen
        tok=@tokens[i]
        i+=1
      end
      tok=@tokens[i]
      return true if tok.is_a? STARTERS_UNARY-STARTERS_ARRAY_OR_STRUCT_INIT
      return false
    end

    def casting
      indent "casting : #{showNext}"
      expect :lparen
      typename
      expect :rparen
      unary
      dedent
    end

    def parenthesized
      indent "parenthesized : #{showNext}"
      expect :lparen
      expression
      expect :rparen
      dedent
    end

    def typename
      indent "typename"
      spec_qualifier_list
      while showNext.is_a? STARTERS_ABSTRACT_DECLARATOR
        abstract_decl
      end
      dedent
    end

    def spec_qualifier_list
      indent "spec_qualifier_list #{showNext.inspect}"
      while showNext.is_a? STARTERS_TYPE_SPECIFIER+STARTERS_TYPE_QUALIFIER
        if showNext.is_a? STARTERS_TYPE_SPECIFIER
          type_specifier
        else
          type_qualifier
        end
      end
      dedent
    end

    STARTERS_TYPE_SPECIFIER=[:void,:char,:short,:int,:long,:float,:signed,:unsigned,:struct,:union,:enum,:ident]
    def type_specifier
      indent "type_specifier #{showNext}"
      if showNext.is_a? STARTERS_TYPE_SPECIFIER
        acceptIt
      else
        raise "ERROR : type_specifier. Expecting one of '#{STARTERS_TYPE_SPECIFIER}' at #{showNext.pos}"
      end
      dedent
    end

  #   abstract_declarator
	#          : pointer
	#          | direct_abstract_declarator
	#          | pointer direct_abstract_declarator
	#          ;
    STARTERS_ABSTRACT_DECLARATOR=[:mul,:lparen,:lbrack]
    def abstract_decl
      indent "abstract_decl"
      if showNext.is_a? STARTERS_ABSTRACT_DECLARATOR
        case showNext.kind
        when :mul
          pointer
        else
          direct_abstract_declarator
        end
      else
        raise "ERROR : in abstract_declarator. Expecting one of #{STARTERS_ABSTRACT_DECLARATOR}"
      end
      dedent
    end

    # pointer
    # 	: '*'
    # 	| '*' type_qualifier_list
    # 	| '*' pointer
    # 	| '*' type_qualifier_list pointer
    # 	;
    STARTERS_TYPE_QUALIFIER=[:const,:volatile]
    def pointer
      expect :mul
      while showNext.is_a? STARTERS_TYPE_QUALIFIER+[:mul]
        case showNext.kind
        when :volatile
          acceptIt
        when :const
          acceptIt
        when :mult
          acceptIt
        end
      end
    end

    def direct_abstract_declarator
      raise
    end

    def unary
      if STARTERS_PRIMARY.include? showNext.kind
        postfix
      elsif showNext.is_a? [:and,:mul,:add,:sub,:tilde,:not]
        acceptIt
        castexp
      else
        case showNext.kind
        when :inc_op
          acceptIt
          unary
        when :dec_op
          acceptIt
          unary
        when :sizeof
          sizeof()
        else
          raise "not an unary"
        end
      end
    end

    def sizeof
      expect :sizeof
      case showNext.kind
      when :lparen
        acceptIt
        typename
        expect :rparen
      else
        unary
      end
    end

    def postfix
      indent "postfix : #{showNext}"
      primary
      while showNext.is_a? [:lbrack,:lparen,:dot,:inc_op,:dec_op,:ptr_op]
        case showNext.kind
        when :lbrack
          acceptIt
          expression
          expect :rbrack
        when :lparen
          acceptIt
          if !showNext.is_a? :rparen
            argument_expr_list
          end
          expect :rparen
        when :dot
          acceptIt
          expect :ident
        when :ptr_op
          acceptIt
          expect :ident
        when :inc_op
          acceptIt
        when :dec_op
          acceptIt
        end
      end
      dedent
    end

    def primary
      case showNext.kind
      when :ident
        acceptIt
      when :integer_lit
        acceptIt
      when :float_lit
        acceptIt
      when :string_lit
        acceptIt
      when :char_lit
        acceptIt
      when :lparen
        acceptIt
        expression
        expect :rparen
      when :lbrace
        array_or_struct_init()
      end
    end

    def argument_expr_list
      expression
      while showNext.is_a? :comma
        acceptIt
        expression
      end
    end

    def array_or_struct_init
      indent "array_or_struct_init"
      expect :lbrace
      elements=[]
      while !showNext.is_a? :rbrace
        elements << (e=expression)
        if showNext.is_a? :comma
          acceptIt
        end
      end
      expect :rbrace
      dedent
      return ArrayOrStructInit.new(elements)
    end

  end#class Parser
end #module

def show_lines str,upto=nil
  lines=str.split(/\n/)
  upto=upto || lines.size
  lines[0..upto].each_with_index do |line,idx|
    puts "#{(idx+1).to_s.ljust(5)}|#{line}"
  end
end

if $PROGRAM_NAME == __FILE__
  require_relative 'dot_printer_rec'
  str=IO.read(ARGV[0])
  show_lines(str)
  t1 = Time.now
  parser=C::Parser.new
  ast=parser.parse(str)
  dot=C::DotPrinter.new.print(ast)
  dot.save_as "test.dot"
  t2 = Time.now
  puts "parsed in     : #{t2-t1} s"
end
