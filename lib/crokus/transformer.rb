
require_relative 'code'

module Crokus

  # here we transform an AST into another AST.
  # we don't use Marshalling.

  class Transformer

    attr_accessor :code

    def initialize
      @ind=-2
      @verbose=true
      @verbose=false
    end

    def transform ast
      ast.accept(self)
    end

    alias :visit :transform

    def visitDesignUnit du,args=nil
      list=du.list.collect{|e| e.accept(self)}
      DesignUnit.new(list)
    end

    def visitDecl decl,args=nil
      type=decl.type.accept(self)
      var=decl.var.accept(self) if decl.var
      init=decl.init.accept(self) if decl.init
      Decl.new(type,var,init)
    end

    def visitInclude incl,args=nil
      name=incl.name.accept(self)
      env=incl.env
      Include.new(name,env)
    end

    def visitDefine define,args=nil
      name=define.name.accept(self)
      expr=define.expr.accept(self)
      Define.new(name,expr)
    end

    def visitTypedef typdef,args=nil
      type=typdef.type.accept(self)
      name=typdef.name.accept(self)
      Typedef.new(type,name)
    end

    def visitType type,args=nil
      precisions=type.precisions.collect{|prc| prc.accept(self)}
      name=type.name.accept(self)
      ret=Type.new(name)
      ret.precisions=precisions
      ret
    end

    def visitPointerTo pto,args=nil
      type=pto.type.accept(self)
      PointerTo.new(type)
    end

    def visitArrayOf aof,args=nil
      type=aof.type.accept(self)
      size=aof.size.accept(self) if aof.size
      ArrayOf.new(type,size)
    end

    def visitStruct struct,args=nil
      name=struct.name.accept(self) if struct.name
      decls=struct.decls.collect{|decl| decl.accept(self)}
      Struct.new(name,decls)
    end

    def visitCasting cast,args=nil
      type=cast.type.accept(self)
      modifier=cast.modifier.accept(self)
      Casting.new(type,modifier)
    end

    def visitCastedExpr cexpr,args=nil
      type=cexpr.type.accept(self)
      expr=cexpr.expr.accept(self)
      CastedExpr.new(type,expr)
    end

    #......... end of types..........

    def visitFunction func,args=nil
      type=func.type.accept(self)
      name=func.name.accept(self)
      args=func.args.collect{|arg| arg.accept(self)}
      body=func.body.accept(self)
      Function.new(name,type,args,body)
    end

    def visitFunctionProto func,args=nil
      type=func.type.accept(self)
      name=func.name.accept(self)
      args=func.args.collect{|arg| arg.accept(self)}
      FunctionProto.new(name,type,args)
    end

    def visitFormalArg formalArg,args=nil
      name=formalArg.name.accept(self) if formalArg.name # e.g : main(void)
      type=formalArg.type.accept(self)
      FormalArg.new(type,name)
    end

    #...........stmts...............
    def visitCommaStmt comma,args=nil
      lhs=comma.lhs.accept(self)
      rhs=comma.rhs.accept(self)
      CommaStmt.new(lhs,rhs)
    end

    def visitAssign assign,args=nil
      lhs=assign.lhs.accept(self)
      op=assign.op.accept(self)
      rhs=assign.rhs.accept(self)
      Assign.new(lhs,op,rhs)
    end

    def visitPostFixAccu accu,args=nil
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op=accu.op.accept(self)
      PostFixAccu.new(lhs,op)
    end

    def visitPreFixAccu accu,args=nil
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op=accu.op.accept(self)
      PreFixAccu.new(lhs,op)
    end

    def visitFunCall fcall,args=nil
      name=fcall.name.accept(self)
      args=fcall.args.collect{|arg| arg.accept(self)}
      FunCall.new(name,args)
    end

    def visitFor for_,args=nil
      init=for_.init.collect{|stmt| stmt.accept(self)}
      cond=for_.cond.accept(self)
      increment=for_.increment.accept(self)
      body=for_.body.accept(self)
      For.new(init,cond,increment,body)
    end

    def visitReturn ret,args=nil
      expr=ret.expr.accept(self) if ret.expr
      Return.new(expr)
    end

    def visitIf if_,args=nil
      cond=if_.cond.accept(self)
      body=if_.body.accept(self)
      else_=if_.else.accept(self) if if_.else
      If.new(cond,body,else_)
    end

    def visitElse else_,args=nil
      body=else_.body.accept(self)
      Else.new(body)
    end

    def visitSwitch sw_,args=nil
      expr =sw_.expr.accept(self)
      cases=sw_.cases.collect{|case_| case_.accept(self)}
      Switch.new(expr,cases)
    end

    def visitCase case_,args=nil
      expr=case_.expr.accept(self)
      body=case_.body.accept(self)
      Case.new(expr,body)
    end

    def visitWhile while_,args=nil
      cond=while_.cond.accept(self)
      body=while_.body.accept(self)
      While.new(cond,body)
    end

    def visitDoWhile while_,args=nil
      cond=while_.cond.accept(self)
      body=while_.body.each{|stmt| stmt.accept(self)}
      DoWhile.new(cond,body)
    end

    def visitBreak brk,args=nil
      Break.new
    end

    def visitContinue cont,args=nil
      Continue.new
    end

    def visitLabelledStmt label,args=nil
      stmt=label.stmt.accept(self)
      LabelledStmt.new(stmt)
    end

    def visitGoto goto,args=nil
      label=goto.label.accept(self)
      Goto.new(label)
    end
    #..........expresions..........
    def visitIdent ident,args=nil
      tok=ident.tok.accept(self)
      Ident.new(tok)
    end

    def visitIntLit lit,args=nil
      tok=lit.tok.accept(self)
      IntLit.new(tok)
    end

    def visitStrLit lit,args=nil
      tok=lit.tok.accept(self)
      StrLit.new(tok)
    end

    def visitCharLit lit,args=nil
      tok=lit.tok.accept(self)
      CharLit.new(tok)
    end

    def visitFloatLit lit,args=nil
      tok=lit.tok.accept(self)
      FloatLit.new(tok)
    end

    def visitBinary expr,args=nil
      lhs=expr.lhs.accept(self)
      op=expr.op.accept(self)
      rhs=expr.rhs.accept(self)
      Binary.new(lhs,op,rhs)
    end

    def visitUnary unary,args=nil
      op=unary.op.accept(self)
      rhs=unary.rhs.accept(self)
      Unary.new(op,rhs,unary.postfix)
    end

    def visitParenth par,args=nil
      e=par.expr.accept(self)
      Parenth.new(e)
    end

    def visitArrow arrow,args=nil
      lhs=arrow.lhs.accept(self)
      rhs=arrow.rhs.accept(self)
      Arrow.new(lhs,rhs)
    end

    def visitIndexed index,args=nil
      lhs=index.lhs.accept(self)
      rhs=index.rhs.accept(self)
      Indexed.new(lhs,rhs)
    end

    def visitArrayOrStructInit init,args=nil
      elements=init.elements.map{|e| e.accept(self)}
      ArrayOrStructInit.new(elements)
    end

    def visitAddressOf ao,args=nil
      e=ao.expr.accept(self)
      AddressOf.new(e)
    end

    def visitDotted dotted,args=nil
      lhs=dotted.lhs.accept(self)
      rhs=dotted.rhs.accept(self)
      Dotted.new(lhs,rhs)
    end

    def visitSizeof sizeof,args=nil
      type=sizeof.type.accept(self)
      Sizeof.new(type)
    end

    def visitDeref deref,args=nil
      e=deref.expr.accept(self)
      Deref.new(e)
    end

    def visitBody body,args=nil
      stmts=body.stmts.map{|stmt| stmt.accept(self)}
      Body.new(stmts)
    end

    def visitToken tok,args=nil
      Token.new [tok.kind,tok.val,tok.pos]
    end
  end #class Visitor
end #module
