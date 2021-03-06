module Crokus

  class TACBuilder < Transformer

    OP_ASSIGN=Token.new([:assign,"=",[0,0]])

    def visitFunction func,args=nil
      puts " "*1+"|--[+] tac builder for '#{func.name}'"
      build func.cfg
    end

    def build cfg
      bb0=cfg.starter
      @tmp_id=0
      @visited=[]
      visit_rec(bb0)
      cfg.name="tac_#{cfg.name}"
      cfg.print
    end

    def new_tmp
      @tmp_id||=0
      tok=Token.create "$"+@tmp_id.to_s
      @tmp_id+=1
      tok
    end

    def visit_rec bb
      @visited << bb
      @current=bb
      @new_stmts=[]
      #@post_stmts=[]
      bb.stmts.each do |stmt|
        @new_stmts << stmt.accept(self)
      end
      bb.stmts=@new_stmts
      #bb.stmts << @post_stmts
      bb.stmts.flatten!
      bb.succs.each do |bb|
        unless @visited.include? bb
          visit_rec(bb)
        end
      end
    end

    def visitAssign assign,args=nil
      assign_1= super(assign)
      if assign_1.lhs.is_a? Indexed
        if (rhs=assign_1.rhs).is_a? Indexed
          rhs=rhs.accept(self)
          tmp=new_tmp()
          @new_stmts << Assign.new(tmp,OP_ASSIGN,rhs)
          assign_1.rhs=tmp
        end
      end
      unless assign.op.kind==:assign
        rhs=assign_1.rhs
        rhs.accept(self)
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,rhs)
        assign_1.rhs=tmp
      end
      assign_1
    end

    def visitITE ite,args=nil
      ret=ITE.new(ite.cond,ite.trueBranch,ite.falseBranch)
      case ite.cond
      when Binary
        cond=ite.cond.accept(self)
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,cond)
        ret.cond=tmp
      when Parenth
        cond=ite.cond.accept(self)
        ret.cond=cond.expr
      end
      ret
    end

    def visitBinary bin,args=nil
      ret=Binary.new(bin.lhs,bin.op,bin.rhs)
      ret.lhs=bin.lhs.accept(self)
      if bin.lhs.respond_to?(:lhs) or bin.lhs.is_a?(FunCall)#Binary,Indexed,etc
        #lhs=bin.lhs.accept(self)
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,ret.lhs)
        ret.lhs=tmp
      end
      ret.rhs=bin.rhs.accept(self)
      if bin.rhs.respond_to?(:lhs) or bin.rhs.is_a?(FunCall) #Binary,Indexed,etc
        # rhs=bin.rhs.accept()
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,ret.rhs)
        ret.rhs=tmp
      end
      return ret
    end

    def visitIndexed idx,args=nil
      lhs=idx.lhs.accept(self)
      ret=Indexed.new(lhs,idx.rhs)
      if idx.rhs.respond_to? :lhs # WARNING : Indexed! Pointed! etc
        lhs=idx.rhs.accept(self)
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,lhs)
        ret.rhs=tmp
      end
      return ret
    end

    def visitParenth par,args=nil
      ret=Parenth.new(par.expr)
      e=par.expr.accept(self)
      tmp=new_tmp()
      @new_stmts||=[]
      @new_stmts << Assign.new(tmp,OP_ASSIGN,e)
      ret.expr=tmp
      return ret
    end

    # TBC
    def visitCondExpr ternary,args=nil
      cond=ternary.cond.accept(self)
      lhs=ternary.lhs.accept(self)
      rhs=ternary.rhs.accept(self)
      CondExpr.new(cond,lhs,rhs)
    end

    # def visitFunCall fcall,args=nil
    #   fcall_n=super(fcall)
    #   fcall_n.args=fcall.args.collect{|arg| arg.accept(self)}
    #   tmp=new_tmp()
    #   @new_stmts << Assign.new(tmp,OP_ASSIGN,fcall_n)
    #   return tmp
    # end

  end
end
