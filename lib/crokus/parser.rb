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
        when :struct
          du << stmt #struct()
        when :typedef
          du << typedef()
        else
          du << decl
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
      expect :lbrace
      while !showNext.is_a? :rbrace
        ret.decls << decl()
        expect :semicolon
      end
      ret.decls.flatten!
      expect :rbrace
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

    def function name,type_
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
      type=type()
      if showNext.is_a? :ident
        name=acceptIt
        while showNext.is_a? :lbrack
          acceptIt
          if showNext.is_a? :rbrack
            acceptIt()
            size=nil
          else
            size=expression()
            expect :rbrack
          end
          type=ArrayOf.new(type,size)
        end
      end
      dedent
      return FormalArg.new(name,type)
    end

    def function_body
      indent "function_body"
      body=Body.new
      expect :lbrace
      while showNext.kind!=:rbrace
        body << stmt()
      end
      expect :rbrace
      dedent
      return body
    end

    def stmt(arg=nil)
      indent "stmt ...#{showNext.kind} #{showNext.pos.first}"
      case showNext.kind
      when :lbrace
        ret=parse_body()
      when :unsigned,:signed,:int,:short,:float,:double,:long,:char,:void
        ret=decl()
      when :ident
        #int a   => decl
        #int * a => pointer_decl
        #scanf(  => func call
        #i= a    => assign
        #i[      => assign
        #i.j     => assign
        #i->     => assign
        case showNext(2).kind
        when :ident
          ret=decl()
        when :mul
          #ret=pointer_decl()
          ret=decl()
        when :lparen
          ret=func_call(as_procedure=true)
        when :assign
          ret=assign()
        when :dot
          ret=assign()
        when :lbrack
          ret=assign()
        when :arrow
          ret=assign()
        when :addadd,:addeq,:subsub,:subeq
          ret=accu()
        when :colon
          expect :ident #label
          expect :colon
          s=stmt()
          ret=LabelledStmt.new(s)
        else
          raise "unknown statement at #{showNext.pos}"
        end
      when :struct
        ret=decl()
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
      when :addadd,:subsub ; #++i
        op=acceptIt #++
        id=expect(:ident)
        ret=Accu.new(nil,op,id)
      when :goto
        ret=parse_goto()

      else
        show_line(showNext.pos)
        raise "unknown statement start at #{showNext.pos} .Got #{showNext.kind} #{showNext.val}"
      end
      maybe :semicolon if arg!=:no_final_semicolon
      dedent
      return ret
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
      body=stmt()
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
          case_body << stmt()
        end
        cases << Case.new(case_e,case_body)
      end
      if showNext.is_a? :default
        acceptIt
        expect :colon
        while showNext.kind!=:rbrace
          stmt()
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
    # int a,b[10],*c
    # int a=1,b=2;
    # int a[]
    # int* f()
    # struct name *ptr;

    def decl
      indent "decl (line #{showNext.pos.first})"
      rets=[] # int a,b,c[]
      t=type()
      #while tokens.any? and showNext.is_a?(:ident)
      if showNext.is_a?(:ident)
        id=acceptIt
        ret=Decl.new(id,t)
        if showNext.is_a?(:lparen)
          rets << ret=function(id,t)
          #puts "after function call next=#{showNext.val}".center(80,'-')
        else
          #warning : indexes seem reversed :
          #          int t[A][B] if ArrayOf(ArrayOf(int,A),B)
          # that is "arrayf of B elements of type ArrayOf A elements of type int"
          tt=t
          while showNext.is_a? :lbrack
            acceptIt #[
            rge=expression
            expect :rbrack #]
            ret.type=ArrayOf.new(tt,rge)
            tt=ret.type
          end
          if showNext.is_a? :assign
            acceptIt
            ret.init=expression()
          end
          rets << ret
          while showNext.is_a? :comma
            acceptIt
            case showNext.kind
            when :ident
              id=acceptIt
              ret=Decl.new(id,t)
              tt=t
              while showNext.is_a? :lbrack
                acceptIt #[
                rge=expression
                expect :rbrack #]
                ret.type=ArrayOf.new(tt,rge)
                tt=ret.type
              end
              if showNext.is_a? :assign
                acceptIt
                ret.init=expression()
              end
            when :mul # int *a,*b <---second!
              acceptIt
              type=PointerTo.new(t.type)
              ret=Decl.new(nil,type,nil)
              while showNext.is_a? :mul
                acceptIt
                ret.type=PointerTo.new(type)
              end
              id=expect(:ident)
              ret.var=id
              rets << ret
              if showNext.is_a? :assign
                acceptIt
                ret.init=expression()
              end
            else
              raise "bug while parsing declaration."
            end
            rets << ret
          end #while
        end
      end
      #puts "end of decl showNext=#{showNext.val}".center(80,'-')
      dedent
      return rets
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

    def assign
      indent "assign"
      #expect :ident
      lhs=term()
      if showNext.is_a? [:assign,:addeq,:subeq,:muleq,:diveq,:modeq]
        op=acceptIt
      end
      rhs=expression()
      dedent
      Assign.new(lhs,op,rhs)
    end

    def type
      indent "type"

      case showNext.kind
      when :signed,:unsigned
        specifier=acceptIt()
        t=type()
        ret=Type.new(t)
        ret.specifiers << specifier
      when :ident,:char,:int,:short,:long,:float,:double,:void
        tok=acceptIt
        modifiers=[]
        if tok.is_a? :long
          if showNext.is_a? :long
            long=acceptIt
            modifiers << long
          end
        end
        ret=Type.new(tok)
        ret.specifiers = modifiers
        case showNext.kind
        when :mul  #int *
          acceptIt
          ret=PointerTo.new(ret)
          while showNext.is_a? :mul
            acceptIt #int **
            ret=PointerTo.new(ret)
          end
        when :lbrack # int[]
          acceptIt

          expect :rbrack
          ret=ArrayOf.new(ret)
        when :char,:int,:short,:long,:float,:double
          t=acceptIt() #long int
          old=ret
          ret=Type.new(t)
          ret.specifiers << old
          case showNext.kind
          when :char,:int,:short,:long,:float,:double
            t=acceptIt
            old=ret
            ret=Type.new(t)
            ret.specifiers << old
            rer.specifiers.flatten!
          end
        end

      when :struct
        if showNext(2).is_a? :lbrace #typdef...struct { }
          ret=struct()
          case showNext.kind
          when :mul  #int *
            acceptIt
            ret=PointerTo.new(ret)
            while showNext.is_a? :mul
              acceptIt #int **
              ret=PointerTo.new(ret)
            end
          when :lbrack # int[]
            acceptIt
            expect :rbrack
            ret=ArrayOf.new(ret)
          end
        elsif showNext(3).is_a? :lbrace #struct a {}
          ret=struct()
          case showNext.kind
          when :mul  #int *
            acceptIt
            ret=PointerTo.new(ret)
            while showNext.is_a? :mul
              acceptIt #int **
              ret=PointerTo.new(ret)
            end
          when :lbrack # int[]
            acceptIt
            expect :rbrack
            ret=ArrayOf.new(ret)
          end
        else #struct name * ptr
          acceptIt #struct
          name=expect(:ident)
          ret=Struct.new(name)
          while showNext.is_a? :mul
            acceptIt #int **
            ret=PointerTo.new(ret)
          end
        end
      end
      dedent
      return ret
    end

    def parse_if
      indent "parse_if"
      expect :if
      cond=expression()
      #dbg_print(cond)
      body=stmt()
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
      ret.body=stmt()
      # if showNext.is_a? :else
      #   ret.body << parse_else()
      # end
      dedent
      return ret
    end

    def parse_while
      indent "parse_while"
      expect :while
      cond=expression()
      body=[]
      # if showNext.is_a? :lbrace
      #   acceptIt
      #   while showNext.kind!=:rbrace
          body << stmt()
      #   end
      #   expect :rbrace
      # end
      dedent
      return While.new(cond,body)
    end

    def parse_for
      indent "parse_for"
      forloop=For.new
      expect :for
      expect :lparen
      forloop.init=parseLoopInit().flatten
      expect :semicolon
      forloop.cond=parseLoopCond()
      expect :semicolon
      forloop.increment=parseLoopEnd()
      expect :rparen
      forloop.body=stmt()
      dedent
      forloop
    end

    def parseLoopInit
      indent "parseLoopInit"
      ret=stmt(:no_final_semicolon)
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
      s=stmt()
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
        body << stmt()
      end
      expect :rbrace
      return body
    end

    #=====================================================
    def expression
      indent "expression...starting by '#{showNext.val}' #{showNext.pos}"
      e1=relation()
      relation_operators = [:lt,:lte,:gt,:gte,:eq,:neq,:dbar]
      while relation_operators.include?(showNext.kind)
        op=acceptIt
        e2=relation()
        e1=Binary.new(e1,op,e2)
      end
      dedent
      return e1
    end

    def relation
      indent "relation"
      e1=factor()
      additive_operators = [:add,:sub,:or]
      while additive_operators.include?(showNext.kind)
        op=acceptIt
        e2=factor()
        e1=Binary.new(e1,op,e2)
      end
      dedent
      return e1
    end

    def factor
      indent "factor"
      e=term()
      multiplicative_operators = [:mul,:div,:gt,:gte,:ampersand,:ampersand2,:mod,:assign]
      while multiplicative_operators.include?(showNext.kind)
        op=acceptIt
        if showNext.is_a? :rparen
          #dont accept it. it will be consumed later in term()
          return Casting.new(e,op.val)
        end
        e2=term()
        e=Binary.new(e,op,e2)
      end
      dedent
      return e
    end

    def unary
      op=acceptIt
      e=expression
      ret=Unary.new(op,e)
    end

    def term
      indent "term...starting by '#{showNext.val}'"
      case showNext.kind
      when :integer_lit,:float_lit,:string_lit,:char_lit
        ret=acceptIt
      when :int,:char,:short,:long,:float,:double,:unsigned,:signed
        ret=type() #???
      when :add,:sub,:not #+42, -42
        ret=unary()
      when :mul #dereference : *(i+1)
        acceptIt
        e=expression
        ret=Deref.new(e)
      when :lparen
        acceptIt
        ret=expression #can be a Casting ! (int *)
        lparen=expect(:rparen)

        #  casted expression ?
        if lparen.pos.first==showNext.pos.first
          case showNext.kind
          when :integer_lit,:float_lit,:string_lit,:char_lit # previous parenth was a cast !
            casting_type=ret
            e=acceptIt
            ret=CastedExpr.new(casting_type,e)
          when :lparen # (int *) (a+b) => second '(' parenth
            casting_type=ret
            acceptIt
            e=expression
            expect :rparen
            ret=CastedExpr.new(casting_type,Parenth.new(e))
          when :ident # (int *) malloc(...) => IDENT=malloc
            casting_type=ret
            e=expression
            ret=CastedExpr.new(casting_type,e)
          end

          while showNext.is_a? [:lbrack,:lparen,:dot,:arrow]
            if par=parenthesized?
              ret=FunCall.new(ret,par)
            end
            if idx=indexed?
              ret=Index.new(ret,idx)
            end
            if dot=doted?
              ret=Pointed.new(ret,dot)
            end
            if arw=arrowed?
              ret=Arrow.new(ret,arw)
            end
          end
        else
          ret=Parenth.new(ret) # normal case
        end
      when :sizeof
        ret=sizeOf()
      when :ampersand,:ident #<======== ident is here

        #new->cle[0][1]
        a=addressof?() #&(ptr+i)->c

        if showNext.is_a? :lparen
          ret=expression
        else
          ret=expect(:ident)
        end

        while showNext.is_a? [:lbrack,:lparen,:dot,:arrow]
          if par=parenthesized?
            ret=FunCall.new(ret,par)
          end
          if idx=indexed?
            ret=Index.new(ret,idx)
          end
          if dot=doted?
            ret=Pointed.new(ret,dot)
          end
          if arw=arrowed?
            ret=Arrow.new(ret,arw)
          end
        end

        if a
          a.expr=ret
          ret=a
        end

      when :lbrace
        ret=array_or_struct_init()
      when :struct # ptr= (struct name *) (malloc...)
        acceptIt
        ret=Struct.new
        ret.name=expect(:ident)
        while showNext.is_a? :mul
          acceptIt
          ret=PointerTo.new(ret)
        end
      else
        raise "unknown term of kind #{showNext.kind}"
      end
      dedent
      return ret
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

    def sizeOf
      indent "sizeof"
      expect :sizeof
      expect :lparen
      t=type
      expect :rparen
      dedent
      return Sizeof.new(t)
    end

    def addressof?
      if showNext.is_a? :ampersand
        acceptIt
      else
        return nil
      end
      return AddressOf.new(nil)
    end

    def indexed?
      if showNext.is_a? :lbrack
        acceptIt
        e=expression
        expect :rbrack
        return e
      else
        return false
      end
    end

    def parenthesized?
      ret=[]
      if showNext.is_a? :lparen
        acceptIt
        if !showNext.is_a? :rparen # f()
          ret << expression #f(a+1
          while showNext.is_a? :comma #f(a+1,b)
            acceptIt
            ret << expression
          end
        end
        expect :rparen
      else
        return nil
      end
      return ret
    end

    def doted?
      if showNext.is_a? :dot
        acceptIt
        expect :ident
      else
        false
      end
    end

    def arrowed?
      if showNext.is_a? :arrow
        acceptIt
        expect :ident
      else
        false
      end
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
