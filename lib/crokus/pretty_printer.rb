
require_relative 'code'
require_relative 'visitor'
require_relative 'cleaner'

module Crokus

  class PrettyPrinter < Visitor

    include Indent
    attr_accessor :code

    def initialize
      @ind=-2
      @verbose=false
    end

    def visit ast
      @code=Code.new
      ast.accept(self)
      c_code=@code.finalize
      c_code=Cleaner.new.clean(c_code)
      return c_code
    end

    def visitDesignUnit du,args=nil
      indent "DesignUnit"
      du.list.each{|e| code << e.accept(self,:body)}
      dedent
    end

    def visitDecl decl,args=nil
      code=Code.new
      type=decl.type.accept(self)

      array_size=""
      t=decl.type

      while t.is_a? ArrayOf
        type=t.name.accept(self)
        size=t.size.accept(self)
        array_size="[#{size}]"+array_size
        t=t.type
      end
      t=nil

      vname=decl.var.accept(self)
      init=decl.init.accept(self) if decl.init

      if init.is_a? Code
        init=" = "+init.finalize
      else
        init=" = "+init
      end if decl.init

      # handle complex declaration that use structs
      if type.is_a? Code
        last=type.lines.pop
        type.lines.each do |line|
          code << line
        end
        last_str=last+" #{vname}#{array_size}#{init}"

        code << last_str
      else
        ret = "#{type} #{vname}#{array_size}#{init}"
      end
      code << ret
      code << ";"
      return code
    end

    def visitInclude include,args=nil
      name=include.name.accept(self)
      case include.env
      when :env
        name="<#{name}>"
      when :local
      end
      return "#include #{name}"
    end

    def visitDefine define,args=nil
      name=define.name.accept(self)
      e=define.expr.accept(self)
      return "#define #{name} #{e}"
    end

    def visitTypedef typdef,args=nil
      type=typdef.type.accept(self)
      name=typdef.name.accept(self)
      return "typedef #{type} #{name};"
    end

    def visitType type,args=nil
      specifiers=type.specifiers.collect{|spec| spec.accept(self)}
      specifiers=specifiers.join
      specifiers+=" " if specifiers.size>0
      name=type.name.accept(self)
      return "#{specifiers}#{name}"
    end

    def visitPointerTo pto,args=nil
      tname=pto.type.accept(self)
      return "#{tname} *"
    end

    def visitArrayOf aof,args=nil
      type=aof.type.accept(self)
      size=aof.size.accept(self) if aof.size
      aof
      "#{type}" #[size] not returned!
    end

    def visitStruct struct,args=nil
      name=struct.name.accept(self) if struct.name
      code=Code.new
      code << "struct #{name} {"
      code.indent=2
      struct.decls.each do |decl|
        code << decl.accept(self)
      end
      code.indent=0
      code << "}"
      return code.finalize
    end

    def visitCasting cast,args=nil
      type=cast.type.accept(self)
      return "#{type} #{cast.modifier}"
    end

    def visitCastedExpr cexpr, args=nil
      type=cexpr.type.accept(self)
      e=cexpr.expr.accept(self)
      return "(#{type}) #{e}"
    end
    #......... end of types..........

    def visitFunction func,args=nil
      code=Code.new
      tname=func.type.accept(self)
      fname=func.name.accept(self)
      args=func.args.collect{|arg| arg.accept(self)}
      args=args.join(",")
      code << "\n#{tname} #{fname}(#{args}) {"
      code.indent=2
      func.body.stmts.each{|stmt| code << stmt.accept(self)}
      code.indent=0
      code << "}"
      return code
    end

    def visitFunctionProto func,args=nil
      tname=func.type.accept(self)
      fname=func.name.accept(self)
      args =func.args.collect{|arg| arg.accept(self)}
      args=args.join(",")
      code = "\n#{tname} #{fname}(#{args})"
      return code
    end

    def visitFormalArg formalArg,args=nil
      tname=formalArg.type.accept(self)
      array_size=""
      t=formalArg.type
      while t.is_a? ArrayOf
        type=t.name.accept(self)
        size=t.size.accept(self) if t.size
        array_size+="[#{size}]"+array_size if tname.size
        t=t.type
      end

      vname=formalArg.name.accept(self) if formalArg.name # e.g : main(void)
      tname+=" " if formalArg.name
      return "#{tname}#{vname}#{array_size}"
    end

    #...........stmts...............

    def visitAssign assign,args=nil
      lhs=assign.lhs.accept(self)
      op =assign.op.accept(self)
      rhs=assign.rhs.accept(self)
      ret="#{lhs} #{op} #{rhs};"
      ret
    end

    def visitAccu accu,args=nil
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op =accu.op.accept(self)
      rhs=accu.rhs.accept(self) if accu.rhs # i++
      ret="#{lhs}#{op}#{rhs};"
      ret
    end

    def visitFunCall fcall,args=nil
      fname=fcall.name.accept(self)
      argus=fcall.args.collect{|argu| argu.accept(self)}
      argus=argus.join(',')
      ret="#{fname}(#{argus})"
      ret+=";" if fcall.as_procedure
      ret
    end

    def visitFor for_,args=nil
      code=Code.new
      init=for_.init.collect{|stmt|
        stmt_init=stmt.accept(self)
        case stmt_init
        when Code
          stmt_init.finalize
        else
          stmt_init
        end
      }
      init=init.join(";")
      cond=for_.cond.accept(self)
      incr=for_.increment.accept(self)
      code << "for(#{init};#{cond};#{incr})"
      code.indent=2
      code << for_.body.accept(self)
      code.indent=0
      return code
    end

    def visitReturn ret,args=nil
      e=ret.expr.accept(self) if ret.expr
      return "return #{e};"
    end

    def visitIf if_,args=nil
      cond=if_.cond.accept(self)
      code=Code.new
      code << "if (#{cond})"
      code.indent=2
      code << if_.body.accept(self)
      code.indent=0
      code << if_.else.accept(self,:body) if if_.else
      return code
    end

    def visitElse else_,args=nil
      code=Code.new
      code << "else"
      code.indent=2
      code << else_.body.accept(self)
      code.indent=0
      return code
    end

    def visitSwitch sw_,args=nil
      e=sw_.expr.accept(self)
      sw_.cases.each{|case_| case_.accept(self)}
      code=Code.new
      code << "switch(#{e})"
      return code
    end

    def visitCase case_,args=nil
      case_.expr.accept(self)
      case_.body.each{|stmt| stmt.accept(self)}
      code=Code.new
      code << "case..."
      return code
    end

    def visitWhile while_,args=nil
      cond=while_.cond.accept(self)
      body=while_.body.collect{|stmt| stmt.accept(self,:body)}
      code=Code.new
      code << "while (#{cond})"
      code.indent=2
      body.each{|stmt| code << stmt}
      code.indent=0
      return code
    end

    def visitDoWhile while_,args=nil
      cond=while_.cond.accept(self)
      code=Code.new
      code << "do"
      code.indent=2
      code << while_.body.accept(self)
      code.indent=0
      code << "while #{cond};"
      return code
    end

    def visitBreak brk,args=nil
      return "break"
    end

    def visitLabelledStmt label,args=nil
      stmt=label.stmt.accept(self)
      code=Code.new
      code << stmt
      return code
    end

    def visitGoto goto,args=nil
      label=goto.label.accept(self)
      return "goto #{label};"
    end

    #..........expresions..........
    def visitBinary expr,args=nil
      lhs=expr.lhs.accept(self)
      op =expr.op.accept(self)
      rhs=expr.rhs.accept(self)
      return "#{lhs}#{op}#{rhs}"
    end

    def visitUnary unary,args=nil
      op=unary.op.accept(self)
      e =unary.rhs.accept(self)
      return "#{op}#{e}"
    end

    def visitParenth par,args=nil
      e=par.expr.accept(self)
      return "(#{e})"
    end

    def visitArrow arrow,args=nil
      lhs=arrow.lhs.accept(self)
      rhs=arrow.rhs.accept(self)
      return "#{lhs}->#{rhs}"
    end

    def visitIndex index,args=nil
      lhs=index.lhs.accept(self)
      rhs=index.rhs.accept(self)
      return "#{lhs}[#{rhs}]"
    end

    def visitArrayOrStructInit init,args=nil
      inits=init.elements.collect{|e| e.accept(self)}
      #handle imbrications
      inits=inits.collect{|init| (init.is_a? Code) ? init.finalize : init}
      code=Code.new
      code << "{"+inits.join(",")+"}"
      return code
    end

    def visitAddressOf ao,args=nil
      e=ao.expr.accept(self)
      return " &#{e} "
    end

    def visitPointed pointed,args=nil
      lhs=pointed.lhs.accept(self)
      rhs=pointed.rhs.accept(self)
      return "#{lhs}.#{rhs}"
    end

    def visitSizeof sizeof,args=nil
      tname=sizeof.type.accept(self)
      return "sizeof(#{tname})"
    end

    def visitDeref deref,args=nil
      e=deref.expr.accept(self)
      return "*#{e}"
    end

    def visitBody body,args=nil
      code=Code.new
      code << "{"
      body.each do |stmt|
        code << stmt.accept(self)
      end
      code << "\b\b}"
      return code
    end
  end #class Visitor
end #module
