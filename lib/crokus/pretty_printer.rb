
require_relative 'code'
require_relative 'visitor'

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
      return @code
    end

    def visitDesignUnit du,args=nil
      indent "DesignUnit"
      du.list.each{|e| code << e.accept(self,:body)}
      dedent
    end

    def visitDecl decl,args=nil
      indent "Decl"
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
      dedent
      return code
    end

    def visitInclude include,args=nil
      indent "Include"
      name=include.name.accept(self)
      dedent
      case include.env
      when :env
        name="<#{name}>"
      when :local
      end
      return "#include #{name}"
    end

    def visitDefine define,args=nil
      indent "Define"
      name=define.name.accept(self)
      e=define.expr.accept(self)
      dedent
      return "#define #{name} #{e}"
    end

    def visitTypedef typdef,args=nil
      indent "Typdef"
      typdef.type.accept(self)
      typdef.name.accept(self)
      dedent
      return "typedef"
    end

    def visitType type,args=nil
      indent "Type"
      specifiers=type.specifiers.collect{|spec| spec.accept(self)}
      specifiers=specifiers.join
      specifiers+=" " if specifiers.size>0
      name=type.name.accept(self)
      dedent
      return "#{specifiers}#{name}"
    end

    def visitPointerTo pto,args=nil
      indent "PointerTo"
      tname=pto.type.accept(self)
      dedent
      return "#{tname} *"
    end

    def visitArrayOf aof,args=nil
      indent "ArrayOf"
      type=aof.type.accept(self)
      size=aof.size.accept(self) if aof.size
      dedent
      aof
      "#{type}" #[size] not returned!
    end

    def visitStruct struct,args=nil
      indent "Struct"
      dedent
      name=struct.name.accept(self) if struct.name
      code=Code.new
      code << "struct #{name} {"
      code.indent=2
      struct.decls.each do |decl|
        code << decl.accept(self,:body)
      end
      code.indent=0
      code << "}"
      return code
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
      indent "Function"
      #puts "function #{func.name.val}"
      code=Code.new
      tname=func.type.accept(self)
      fname=func.name.accept(self)
      args=func.args.collect{|arg| arg.accept(self)}
      args=args.join(",")
      dedent
      code << "\n#{tname} #{fname}(#{args}) {"
      code.indent=2
      func.body.stmts.each{|stmt| code << stmt.accept(self)}
      code.indent=0
      code << "}"
      return code
    end

    def visitFunctionProto func,args=nil
      indent "FunctionProto"
      tname=func.type.accept(self)
      fname=func.name.accept(self)
      args =func.args.collect{|arg| arg.accept(self)}
      args=args.join(",")
      dedent
      code = "\n#{tname} #{fname}(#{args})"
      return code
    end

    def visitFormalArg formalArg,args=nil
      indent "FormalArg"
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
      dedent
      return "#{tname}#{vname}#{array_size}"
    end

    #...........stmts...............

    def visitAssign assign,args=nil
      indent "Assign"
      lhs=assign.lhs.accept(self)
      op =assign.op.accept(self)
      rhs=assign.rhs.accept(self)
      dedent
      ret="#{lhs} #{op} #{rhs}"
      #ret+=";"
      ret
    end

    def visitAccu accu,args=nil
      indent "Accu"
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op =accu.op.accept(self)
      rhs=accu.rhs.accept(self) if accu.rhs # i++
      dedent
      ret="#{lhs}#{op}#{rhs}"
      ret
    end

    def visitFunCall fcall,args=nil
      indent "FunCall #{args}"
      fname=fcall.name.accept(self)
      argus=fcall.args.collect{|argu| argu.accept(self)}
      argus=argus.join(',')
      dedent
      ret="#{fname}(#{argus})"
      ret
    end

    def visitFor for_,args=nil
      indent "For"
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
      code << "for(#{init};#{cond};#{incr}){"
      code.indent=2
      code << for_.body.accept(self)
      code.indent=0
      code << "}"
      dedent
      return code
    end

    def visitReturn ret,args=nil
      indent "Return"
      e=ret.expr.accept(self) if ret.expr
      dedent
      return "return #{e}"
    end

    def visitIf if_,args=nil
      indent "If"
      cond=if_.cond.accept(self)
      dedent
      code=Code.new
      code << "if #{cond} {"
      code.indent=2
      code << if_.body.accept(self)
      code.indent=0
      code << "}"
      code << if_.else.accept(self,:body) if if_.else
      return code
    end

    def visitElse else_,args=nil
      indent "Else"
      dedent
      code=Code.new
      code << "else {"
      code.indent=2
      code << else_.body.accept(self)
      code.indent=0
      code << "}"
      return code
    end

    def visitSwitch sw_,args=nil
      indent "Switch"
      e=sw_.expr.accept(self)
      sw_.cases.each{|case_| case_.accept(self)}
      dedent
      code=Code.new
      code << "switch(#{e}){"
      code << "}"
      return code
    end

    def visitCase case_,args=nil
      indent "Case"
      case_.expr.accept(self)
      case_.body.each{|stmt| stmt.accept(self)}
      dedent
      code=Code.new
      code << "case..."
      return code
    end

    def visitWhile while_,args=nil
      indent "While"
      cond=while_.cond.accept(self)
      body=while_.body.collect{|stmt| stmt.accept(self,:body)}
      dedent
      code=Code.new
      code << "while #{cond}{"
      code.indent=2
      body.each{|stmt| code << stmt}
      code.indent=0
      code << "}"
      return code
    end

    def visitDoWhile while_,args=nil
      indent "DoWhile"
      cond=while_.cond.accept(self)
      dedent
      code=Code.new
      code << "do {"
      code.indent=2
      while_.body.stmts.each{|stmt| code << stmt.accept(self)}
      code.indent=0
      code << "} while #{cond}"
      return code
    end

    def visitBreak brk,args=nil
      indent "Break"
      dedent
      return "break"
    end

    def visitLabelledStmt label,args=nil
      indent "LabelledStmt"
      stmt=label.stmt.accept(self)
      dedent
      code=Code.new
      code << stmt
      return code
    end

    def visitGoto goto,args=nil
      indent "Goto"
      label=goto.label.accept(self)
      dedent
      return "goto #{label}"
    end

    #..........expresions..........
    def visitBinary expr,args=nil
      indent "Binary"
      lhs=expr.lhs.accept(self)
      op =expr.op.accept(self)
      rhs=expr.rhs.accept(self)
      dedent
      return "#{lhs}#{op}#{rhs}"
    end

    def visitUnary unary,args=nil
      indent "Unary"
      op=unary.op.accept(self)
      e =unary.rhs.accept(self)
      dedent
      return "#{op}#{e}"
    end

    def visitParenth par,args=nil
      indent "Parenth"
      e=par.expr.accept(self)
      dedent
      return "(#{e})"
    end

    def visitArrow arrow,args=nil
      indent "arrow"
      lhs=arrow.lhs.accept(self)
      rhs=arrow.rhs.accept(self)
      dedent
      return "#{lhs}->#{rhs}"
    end

    def visitIndex index,args=nil
      indent "Index"
      lhs=index.lhs.accept(self)
      rhs=index.rhs.accept(self)
      dedent
      return "#{lhs}[#{rhs}]"
    end

    def visitArrayOrStructInit init,args=nil
      indent "ArrayOrStructInit"
      inits=init.elements.collect{|e| e.accept(self)}
      dedent
      #handle imbrications
      inits=inits.collect{|init| (init.is_a? Code) ? init.finalize : init}
      code=Code.new
      code << "{"+inits.join(",")+"}"
      return code
    end

    def visitAddressOf ao,args=nil
      indent "AddressOf"
      e=ao.expr.accept(self)
      dedent
      return " &#{e} "
    end

    def visitPointed pointed,args=nil
      indent "Pointed"
      pointed.lhs.accept(self)
      pointed.rhs.accept(self)
      dedent
      return "#{lhs}.#{rhs}"
    end

    def visitSizeof sizeof,args=nil
      indent "Sizeof"
      tname=sizeof.type.accept(self)
      dedent
      return "sizeof(#{tname})"
    end

    def visitDeref deref,args=nil
      indent "Deref"
      e=deref.expr.accept(self)
      dedent
      return "*#{e}"
    end

    def visitBody body,args=nil
      indent "Body"
      code=Code.new
      code << "{"
      body.each{|stmt| code << stmt.accept(self)+";"}
      code << "}"
      dedent
      return code
    end
  end #class Visitor
end #module
