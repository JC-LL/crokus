module Crokus

  class Visitor

    include Indent

    def initialize
      @ind=-2
      @verbose=true
      @verbose=false
    end

    def visit ast
      ast.accept(self)
    end

    def visitToken tok, args=nil
      tok
    end

    def visitDesignUnit du,args=nil
      indent "DesignUnit"
      du.list.each{|e| e.accept(self)}
      dedent
      du
    end

    def visitDecl decl,args=nil
      indent "Decl"
      decl.type.accept(self)
      decl.var.accept(self)
      decl.init.accept(self) if decl.init
      dedent
      decl
    end

    def visitInclude include,args=nil
      indent "Include"
      include.name.accept(self)
      dedent
      include
    end

    def visitDefine define,args=nil
      indent "Define"
      define.name.accept(self)
      define.expr.accept(self)
      dedent
      define
    end

    def visitTypedef typdef,args=nil
      indent "Typdef"
      typdef.type.accept(self)
      typdef.name.accept(self)
      dedent
      typedef
    end

    def visitType type,args=nil
      indent "Type"
      type.specifiers.each{|spec| spec.accept(self)}
      type.name.accept(self)
      dedent
      type
    end

    def visitPointerTo pto,args=nil
      indent "PointerTo"
      pto.type.accept(self)
      dedent
      pto
    end

    def visitArrayOf aof,args=nil
      indent "ArrayOf"
      aof.type.accept(self)
      aof.size.accept(self) if aof.size
      dedent
      aof
    end

    def visitStruct struct,args=nil
      indent "Struct"
      dedent
      struct
    end

    def visitCasting cast,args=nil
      indent "Casting"
      cast.type.accept(self)
      dedent
      cast
    end

    def visitCastedExpr cexpr,args=nil
      indent "CastedExpr"
      cexpr.type.accept(self)
      cexpr.expr.accept(self)
      dedent
      cexpr
    end

    #......... end of types..........

    def visitFunction func,args=nil
      indent "Function"
      func.type.accept(self)
      func.name.accept(self)
      func.args.each{|arg| arg.accept(self)}
      func.body.accept(self)
      dedent
      func
    end

    def visitFunctionProto func,args=nil
      indent "FunctionProto"
      func.type.accept(self)
      func.name.accept(self)
      func.args.each{|arg| arg.accept(self)}
      dedent
      func
    end

    def visitFormalArg formalArg,args=nil
      indent "FormalArg"
      formalArg.name.accept(self) if formalArg.name # e.g : main(void)
      formalArg.type.accept(self)
      dedent
      formalArg
    end

    #...........stmts...............
    def visitCommaStmt comma,args=nil
      lhs=comma.lhs.accept(self)
      rhs=comma.rhs.accept(self)
      comma
    end

    def visitAssign assign,args=nil
      assign.lhs.accept(self)
      assign.op.accept(self)
      assign.rhs.accept(self)
      assign
    end

    def visitPostFixAccu accu,args=nil
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op =accu.op.accept(self)
      accu
    end

    def visitPreFixAccu accu,args=nil
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op =accu.op.accept(self)
      accu
    end

    def visitFunCall fcall,args=nil
      indent "FunCall"
      fcall.name.accept(self)
      fcall.args.each{|arg| arg.accept(self)}
      dedent
      fcall
    end

    def visitFor for_,args=nil
      indent "For"
      for_.init.each{|stmt| stmt.accept(self)}
      for_.cond.accept(self)
      for_.increment.accept(self)
      for_.body.accept(self)
      dedent
      for_
    end

    def visitReturn ret,args=nil
      indent "Return"
      ret.expr.accept(self) if ret.expr
      dedent
      ret
    end

    def visitIf if_,args=nil
      indent "If"
      if_.cond.accept(self)
      if_.body.accept(self)
      dedent
      if_
    end

    def visitSwitch sw_,args=nil
      indent "Switch"
      sw_.expr.accept(self)
      sw_.cases.each{|case_| case_.accept(self)}
      dedent
      sw_
    end

    def visitCase case_,args=nil
      indent "Case"
      case_.expr.accept(self)
      case_.body.accept(self)
      dedent
      case_
    end

    def visitWhile while_,args=nil
      indent "While"
      while_.cond.accept(self)
      while_.body.each{|stmt| stmt.accept(self)}
      dedent
      while_
    end

    def visitDoWhile while_,args=nil
      indent "DoWhile"
      while_.cond.accept(self)
      while_.body.each{|stmt| stmt.accept(self)}
      dedent
      while_
    end

    def visitBreak brk,args=nil
      indent "Break"
      dedent
      brk
    end

    def visitContinue brk,args=nil
      indent "Continue"
      dedent
      brk
    end

    def visitLabelledStmt label,args=nil
      indent "LabelledStmt"
      dedent
      label
    end

    def visitGoto goto,args=nil
      indent "Goto"
      goto.label.accept(self)
      dedent
      goto
    end
    #..........expresions..........
    def visitIdent ident,args=nil
      ident
    end

    def visitIntLit lit,args=nil
      lit
    end

    def visitStrLit lit,args=nil
      lit
    end

    def visitCharLit lit,args=nil
      lit
    end

    def visitFloatLit lit,args=nil
      lit
    end

    def visitBinary expr,args=nil
      indent "Binary"
      expr.lhs.accept(self)
      expr.op.accept(self)
      expr.rhs.accept(self)
      dedent
      expr
    end

    def visitUnary unary,args=nil
      indent "Unary"
      dedent
      unary
    end

    def visitParenth par,args=nil
      indent "Parenth"
      par.expr.accept(self)
      dedent
      par
    end

    def visitArrow arrow,args=nil
      indent "arrow"
      arrow.lhs.accept(self)
      arrow.rhs.accept(self)
      dedent
    end

    def visitIndexed index,args=nil
      indent "Index"
      index.lhs.accept(self)
      index.rhs.accept(self)
      dedent
    end

    def visitArrayOrStructInit init,args=nil
      indent "ArrayOrStructInit"
      init.elements.each{|e| e.accept(self)}
      dedent
    end

    def visitAddressOf ao,args=nil
      indent "AddressOf"
      dedent
    end

    def visitPointed pointed,args=nil
      indent "Pointed"
      pointed.lhs.accept(self)
      pointed.rhs.accept(self)
      dedent
    end

    def visitSizeof sizeof,args=nil
      indent "Sizeof"
      sizeof.type.accept(self)
      dedent
    end

    def visitDeref deref,args=nil
      indent "Deref"
      dedent
    end

    def visitBody body,args=nil
      indent "body"
      body.stmts.each{|stmt| stmt.accept(self)}
      dedent
    end
  end #class Visitor
end #module
