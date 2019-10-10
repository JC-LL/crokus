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
      pp tokens[0..n-1].collect{|tok| tok.inspect}
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
      du.list.flatten!
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

    def parse_struct
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
      type=parse_type()
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
      @current_type=type=parse_type()
      d=declarator
      a=arrayed?(type)
      #parenthesized?
      dedent
      return FormalArg.new(type,d)
    end

    def function_body
      indent "function_body"
      body=Body.new
      expect :lbrace
      while showNext.kind!=:rbrace
        s=statement()
        body << s if s
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
      when :continue
        acceptIt
        ret=Continue.new
      when :do
        ret=do_while()
      when :goto
        ret=parse_goto()
      when :ident
        case showNext(2).kind
        when :ident
          ret=declaration
        when :colon
          l=parse_label
          s=statement
          ret=LabeledStmt.new(l,s)
        else
          ret=expression_statement
        end
      when :const,:volatile
        declaration
      when :semicolon
        acceptIt
        #ret=expression_statement
      when :inc_op,:dec_op,:mul
        ret=expression_statement
      else
        show_line(showNext.pos)
        raise "unknown statement start at #{showNext.pos} .Got #{showNext.kind} #{showNext.val}"
      end
      maybe :semicolon
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
      ret=Switch.new(e,cases=[],default=nil)
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
        default_body=Body.new
        while showNext.kind!=:rbrace
          default_body << statement()
        end
        ret.default=default_body
      end
      expect :rbrace
      dedent
      return ret
    end

    def parse_return
      indent "parse_return"
      expect :return
      unless showNext.is_a? :semicolon
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
      ret=[]
      @current_type=type=parse_type()
      d=declarator()
      a=arrayed?(type)
      if a
        type=a
      end
      func=parenthesized?
      if func
        func.type=type
        ret << func #func
        return ret
      end
      init=initialization?
      ret << Decl.new(type,d,init)
      while tokens.any? and showNext.is_a?(:comma)
        acceptIt
        ptr=pointed?
        if ptr
          type2=PointerTo.new(type)
        end
        d2=declarator
        a2=arrayed?(type)
        i2=initialization?
        ret << Decl.new(type2||type,d2)
      end
      if tokens.any?
        maybe :semicolon
      end
      return ret
    end

    def declarator
      if showNext.is_a? :ident
        ret=@current_ident=Ident.new(acceptIt)
      end
      return ret
    end

    def pointed?
      return if tokens.empty?
      while showNext.is_a? :mul
        acceptIt
      end
    end

    def arrayed?(type)
      return if tokens.empty?
      while showNext.is_a? :lbrack
        acceptIt
        if showNext.is_a? :rbrack
          acceptIt
          type=ArrayOf.new(type,IntLit.new(ZERO))
        else
          e=expression
          type=ArrayOf.new(type,e)
          expect :rbrack
        end
      end
      return type
    end

    def initialization?
      return if tokens.empty?
      if showNext.is_a? :assign
        expect :assign
        e=expression
        return e
      end
    end

    def parenthesized?
      return if tokens.empty?
      if showNext.is_a? :lparen
        f=function_decl(@current_ident,@current_type)
        return f
      end
    end

    def parse_type
      indent "parse_type"
      ret=Type.new(nil)

      ret.precisions << spec_qualifier?() # const, volatile
      if showNext.is_a? [:signed,:unsigned]
        ret.precisions << acceptIt
      end

      case showNext.kind
      when :ident,:char,:int,:short,:long,:float,:double,:void
        ret.name=acceptIt
        while showNext.is_a? [:char,:int,:short,:long,:float,:double,:void]
          ret.precisions << ret.name
          ret.name=acceptIt
        end
        ret.precisions.flatten!
      when :struct
        ret=parse_struct()
      when :typedef
        ret=typedef()
      else
        raise "Parsing ERROR in type declaration: '#{showNext}'"
      end

      while showNext.is_a? [:mul,:lparen]
        case showNext.kind
        when :mul
          acceptIt
          ret=PointerTo.new(ret)
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
      return ret
    end

    def spec_qualifier?
      list=[]
      while showNext.is_a? STARTERS_TYPE_QUALIFIER
        case showNext.kind
        when :volatile
          list << acceptIt
        when :const
          list << acceptIt
        end
      end
      list
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
      body=Body.new
      if showNext.is_a? :lbrace
        lbrace=acceptIt
      end
      body << statement()
      if lbrace
        until showNext.is_a? :rbrace
          body << statement
        end
        expect :rbrace
      end
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
      body=statement()
      dedent
      return While.new(cond,body)
    end

    def parse_for
      indent "parse_for"
      forloop=For.new
      expect :for
      expect :lparen
      forloop.init << expression_statement
      forloop.cond = expression()
      expect :semicolon
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
        e=expression
        expect :semicolon
        return e
      end
    end
    #===============================================================
    def debug
      puts " "*@indentation+@tokens[0..4].map{|t| "'#{t.val}'"}.join(" ")
    end
    #===============================================================
    def expression
      indent "expression : #{showNext}"
      e1=assign()
      while showNext.is_a? :comma
        acceptIt
        e2=assign()
        e1=CommaStmt.new(e1,e2)
      end
      dedent
      return e1
    end

    STARTERS_ARRAY_OR_STRUCT_INIT=[:lbrace]
    STARTERS_PRIMARY=[:ident,:integer_lit,:float_lit,:string_lit,:char_lit,:lparen]+STARTERS_ARRAY_OR_STRUCT_INIT
    UNARY_OP=[:and,:mul,:add,:sub,:tilde,:not]
    STARTERS_UNARY=[:inc_op,:dec_op,:sizeof]+STARTERS_PRIMARY+UNARY_OP
    ASSIGN_OP=[:assign,:add_assign,:sub_assign,:mul_assign,:div_assign,:mod_assign,:xor_assign]

    def assign
      indent "assign : #{showNext}"
      e1=cond_expr
      while showNext.is_a? ASSIGN_OP
        op=acceptIt
        e2=assign
        e1=Assign.new(e1,op,e2)
      end
      dedent
      return e1
    end

    def cond_expr
      indent "cond_expr : #{showNext}"
      e1=logor
      while showNext.is_a? :qmark
        acceptIt
        e2=expression
        expect :colon
        e3=cond_expr
        e1=CondExpr.new(e1,e2,e3)
      end
      dedent
      return e1
    end

    def logor
      indent "logor : #{showNext}"
      e1=logand
      while showNext.is_a? :oror
        op=acceptIt
        e2=logand
        e1=Or2.new(e1,op,e2)
      end
      dedent
      return e1
    end

    def logand
      indent "logand : #{showNext}"
      e1=inclor
      while showNext.is_a? :andand
        op=acceptIt
        e2=inclor
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def inclor
      indent "inclor : #{showNext}"
      e1=exclor
      while showNext.is_a? :or
        op=acceptIt
        e2=exclor
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def exclor
      indent "exclor : #{showNext}"
      e1=andexp
      while showNext.is_a? :xor
        op=acceptIt
        e2=andexp
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def andexp
      indent "andexp : #{showNext}"
      e1=eqexp
      while showNext.is_a? :and
        op=acceptIt
        e2=eqexp
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def eqexp
      indent "eqexp : #{showNext}"
      e1=relexp
      while showNext.is_a? [:eq,:neq]
        op=acceptIt
        e2=relexp
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def relexp
      indent "relexp : #{showNext}"
      e1=shiftexp
      while showNext.is_a? [:lte,:lt,:gte,:gt ]
        op=acceptIt
        e2=shiftexp
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def shiftexp
      indent "shiftexp : #{showNext}"
      e1=additive
      while showNext.is_a? [:shift_l,:shift_r]
        op=acceptIt
        e2=additive
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def additive
      indent "addititve : #{showNext}"
      e1=multitive
      while showNext.is_a? [:add,:sub]
        op=acceptIt
        e2=multitive
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def multitive
      indent "multitive : #{showNext}"
      e1=castexp
      while showNext.is_a? [:mul,:div,:mod]
        op=acceptIt
        e2=castexp
        e1=Binary.new(e1,op,e2)
      end
      dedent
      e1
    end

    def castexp
      indent "castexpr : #{showNext}"
      case showNext.kind
      when :lparen # parenth expr OR casting !
        res=is_casting?
        puts "casting? : #{res}" if $options[:verbose]
        if res
          e=casting
        else
          e=parenthesized
        end
      else
        e=unary
      end
      dedent
      return e
    end

    def is_casting?
      i=0
      tok=DUMMY
      while tok.kind!=:rparen
        tok=@tokens[i]
        i+=1
      end
      tok=@tokens[i]
      return false if tok.is_a? [:mul,:add,:sub]
      return true if tok.is_a? STARTERS_UNARY-STARTERS_ARRAY_OR_STRUCT_INIT
      return false
    end

    def casting
      puts "casting : #{showNext}" if $options[:verbose]
      expect :lparen
      #typename
      t=parse_type
      expect :rparen
      u=unary
      CastedExpr.new(t,u)
    end

    def parenthesized
      indent "parenthesized : #{showNext}"
      expect :lparen
      e=expression
      expect :rparen
      dedent
      return Parenth.new(e)
    end

    def typename
      indent "typename"
      type=specifier_qualifier
      while showNext.is_a? STARTERS_ABSTRACT_DECLARATOR
        list << abstract_decl
      end
      dedent
      list
    end

    def spec_qualifier_list
      indent "spec_qualifier_list #{showNext.inspect}"
      while showNext.is_a? STARTERS_TYPE_SPECIFIER+STARTERS_TYPE_QUALIFIER
        if showNext.is_a? STARTERS_TYPE_SPECIFIER
          list << type_specifier
        else
          list << type_qualifier
        end
      end
      dedent
      list
    end

    STARTERS_TYPE_SPECIFIER=[:void,:char,:short,:int,:long,:float,:signed,:unsigned,:struct,:union,:enum,:ident]
    def type_specifier
      type=Type.new(nil,[])
      indent "type_specifier #{showNext}"
      if showNext.is_a? STARTERS_TYPE_SPECIFIER
        ret=acceptIt
        type.name=ret
      else
        raise "ERROR : type_specifier. Expecting one of '#{STARTERS_TYPE_SPECIFIER}' at #{showNext.pos}"
      end
      dedent
      type
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
        u=postfix
      elsif showNext.is_a? [:and,:mul,:add,:sub,:tilde,:not]
        op=acceptIt
        e=castexp
        u=Unary.new(op,e)
      else
        case showNext.kind
        when :inc_op
          op=acceptIt
          u=unary
          u=PreFixAccu.new(op,u)
        when :dec_op
          op=acceptIt
          u=unary
          u=PreFixAccu.new(op,u)
        when :sizeof
          u=sizeof()
        else
          raise "not an unary"
        end
      end
      return u
    end

    def sizeof
      expect :sizeof
      case showNext.kind
      when :lparen
        acceptIt
        #e=typename
        e=parse_type
        expect :rparen
      else
        #e=unary
        e=expression
      end
      Sizeof.new(e)
    end

    def postfix
      indent "postfix : #{showNext}"
      e1=primary
      while showNext.is_a? [:lbrack,:lparen,:dot,:inc_op,:dec_op,:ptr_op]
        case showNext.kind
        when :lbrack
          acceptIt
          e2=expression
          expect :rbrack
          e1=Indexed.new(e1,e2)
        when :lparen
          acceptIt
          args=[]
          if !showNext.is_a? :rparen
            args=argument_expr_list
          end
          expect :rparen
          args=linearize_comma_stmt(args)
          e1=FunCall.new(e1,args)
        when :dot
          acceptIt
          e2=Ident.new(expect :ident)
          e1=Dotted.new(e1,e2)
        when :ptr_op
          op=acceptIt
          expect :ident
        when :inc_op,:dec_op
          op=acceptIt
          e1=PostFixAccu.new(e1,op)
        end
      end
      dedent
      e1
    end

    def linearize_comma_stmt ary
      ary.collect do |stmt|
        case stmt
        when CommaStmt
          stmt.to_list
        else
          stmt
        end
      end.flatten
    end

    def primary
      case showNext.kind
      when :ident
        return Ident.new(acceptIt)
      when :integer_lit
        return IntLit.new(acceptIt)
      when :float_lit
        return FloatLit.new(acceptIt)
      when :string_lit
        return StrLit.new(acceptIt)
      when :char_lit
        return CharLit.new(acceptIt)
      when :lparen
        acceptIt
        e=expression
        expect :rparen
        return Parenth.new(e)
      when :lbrace
        return array_or_struct_init()
      end
    end

    def argument_expr_list
      list=[]
      list << expression
      while showNext.is_a? :comma
        acceptIt
        list << expression
      end
      list
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
