module Crokus

  class Visitor

    include Indent

    def initialize
      @ind=-2
      @verbose=true
      @verbose=false
    end

    def visit ast,args=nil
      ast.accept(self,args)
    end

    def visitToken tok, args=nil
      tok
    end

    def visitDesignUnit du,args=nil
      indent "DesignUnit"
      du.list.each{|e| e.accept(self,args)}
      dedent
      du
    end

    def visitDecl decl,args=nil
      indent "Decl"
      decl.type.accept(self,args)
      decl.var.accept(self,args) if decl.var #case of struct decl only.
      decl.init.accept(self,args) if decl.init
      dedent
      decl
    end

    def visitInclude include,args=nil
      indent "Include"
      include.name.accept(self,args)
      dedent
      include
    end

    def visitDefine define,args=nil
      indent "Define"
      define.name.accept(self,args)
      define.expr.accept(self,args)
      dedent
      define
    end

    def visitTypedef typdef,args=nil
      indent "Typdef"
      typdef.type.accept(self,args)
      typdef.name.accept(self,args)
      dedent
      typdef
    end

    def visitType type,args=nil
      indent "Type"
      type.precisions.each{|precision| precision.accept(self,args)}
      type.name.accept(self,args)
      dedent
      type
    end

    def visitPointerTo pto,args=nil
      indent "PointerTo"
      pto.type.accept(self,args)
      dedent
      pto
    end

    def visitArrayOf aof,args=nil
      indent "ArrayOf"
      aof.type.accept(self,args)
      aof.size.accept(self,args) if aof.size
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
      cast.type.accept(self,args)
      dedent
      cast
    end

    def visitCastedExpr cexpr,args=nil
      indent "CastedExpr"
      cexpr.type.accept(self,args)
      cexpr.expr.accept(self,args)
      dedent
      cexpr
    end

    #......... end of types..........

    def visitFunction func,args=nil
      indent "Function"
      func.type.accept(self,args)
      func.name.accept(self,args)
      func.args.each{|arg| arg.accept(self,args)}
      func.body.accept(self,args)
      dedent
      func
    end

    def visitFunctionProto func,args=nil
      indent "FunctionProto"
      func.type.accept(self,args)
      func.name.accept(self,args)
      func.args.each{|arg| arg.accept(self,args)}
      dedent
      func
    end

    def visitFormalArg formalArg,args=nil
      indent "FormalArg"
      formalArg.name.accept(self,args) if formalArg.name # e.g : main(void)
      formalArg.type.accept(self,args)
      dedent
      formalArg
    end

    #...........stmts...............
    def visitCommaStmt comma,args=nil
      lhs=comma.lhs.accept(self,args)
      rhs=comma.rhs.accept(self,args)
      comma
    end

    def visitAssign assign,args=nil
      assign.lhs.accept(self,args)
      assign.op.accept(self,args)
      assign.rhs.accept(self,args)
      assign
    end

    def visitPostFixAccu accu,args=nil
      lhs=accu.lhs.accept(self,args) if accu.lhs #++i
      op =accu.op.accept(self,args)
      accu
    end

    def visitPreFixAccu accu,args=nil
      lhs=accu.lhs.accept(self,args) if accu.lhs #++i
      op =accu.op.accept(self,args)
      accu
    end

    def visitFunCall fcall,args=nil
      indent "FunCall"
      fcall.name.accept(self,args)
      fcall.args.each{|arg| arg.accept(self,args)}
      dedent
      fcall
    end

    def visitFor for_,args=nil
      indent "For"
      for_.init.each{|stmt| stmt.accept(self,args)}
      for_.cond.accept(self,args)
      for_.increment.accept(self,args)
      for_.body.accept(self,args)
      dedent
      for_
    end

    def visitReturn ret,args=nil
      indent "Return"
      ret.expr.accept(self,args) if ret.expr
      dedent
      ret
    end

    def visitIf if_,args=nil
      indent "If"
      if_.cond.accept(self,args)
      if_.body.accept(self,args)
      dedent
      if_
    end

    def visitSwitch sw_,args=nil
      indent "Switch"
      sw_.expr.accept(self,args)
      sw_.cases.each{|case_| case_.accept(self,args)}
      dedent
      sw_
    end

    def visitCase case_,args=nil
      indent "Case"
      case_.expr.accept(self,args)
      case_.body.accept(self,args)
      dedent
      case_
    end

    def visitWhile while_,args=nil
      indent "While"
      while_.cond.accept(self,args)
      while_.body.each{|stmt| stmt.accept(self,args)}
      dedent
      while_
    end

    def visitDoWhile while_,args=nil
      indent "DoWhile"
      while_.cond.accept(self,args)
      while_.body.each{|stmt| stmt.accept(self,args)}
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
      goto.label.accept(self,args)
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

    def visitCondExpr cexpr,args=nil
      indent "condexpr"
      cexpr.cond.accept(self,args)
      cexpr.lhs.accept(self,args)
      cexpr.rhs.accept(self,args)
      dedent
      cexpr
    end

    def visitBinary expr,args=nil
      indent "Binary"
      expr.lhs.accept(self,args)
      expr.op.accept(self,args)
      expr.rhs.accept(self,args)
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
      par.expr.accept(self,args)
      dedent
      par
    end

    def visitArrow arrow,args=nil
      indent "arrow"
      arrow.lhs.accept(self,args)
      arrow.rhs.accept(self,args)
      dedent
    end

    def visitIndexed index,args=nil
      indent "Index"
      index.lhs.accept(self,args)
      index.rhs.accept(self,args)
      dedent
    end

    def visitArrayOrStructInit init,args=nil
      indent "ArrayOrStructInit"
      init.elements.each{|e| e.accept(self,args)}
      dedent
    end

    def visitAddressOf ao,args=nil
      indent "AddressOf"
      dedent
    end

    def visitPointed pointed,args=nil
      indent "Pointed"
      pointed.lhs.accept(self,args)
      pointed.rhs.accept(self,args)
      dedent
    end

    def visitSizeof sizeof,args=nil
      indent "Sizeof"
      sizeof.type.accept(self,args)
      dedent
      sizeof
    end

    def visitDeref deref,args=nil
      indent "Deref"
      dedent
    end

    def visitBody body,args=nil
      indent "body"
      body.stmts.each{|stmt| stmt.accept(self,args)}
      dedent
    end
  end #class Visitor
end #module
