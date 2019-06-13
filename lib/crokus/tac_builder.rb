module Crokus

  class TACBuilder < Transformer

    OP_ASSIGN=Token.new([:assign,"=",[0,0]])

    def visitFunction func,args=nil
      puts "   |--> tac builder for '#{func.name}'"
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
      tok=Token.create "$"+@tmp_id.to_s
      @tmp_id+=1
      tok
    end

    def visit_rec bb
      #puts "- visiting #{bb.label}"
      @visited << bb
      @current=bb
      @new_stmts=[]
      bb.stmts.each do |stmt|
        #puts "... "+stmt.str
        @new_stmts << stmt.accept(self)
      end
      bb.stmts=@new_stmts
      bb.succs.each do |bb|
        unless @visited.include? bb
          visit_rec(bb)
        end
      end
    end

    def visitITE ite,args=nil
      ret=ITE.new(ite.cond,ite.trueBranch,ite.falseBranch)
      if ite.cond.is_a? Binary
        cond=ite.cond.accept(self)
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,cond)
        ret.cond=tmp
      end
      ret
    end

    def visitBinary bin,args=nil
      ret=Binary.new(bin.lhs,bin.op,bin.rhs)
      if bin.lhs.is_a? Binary
        lhs=bin.lhs.accept(self)
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,lhs)
        ret.lhs=tmp
      end
      if bin.rhs.is_a? Binary
        rhs=bin.rhs.accept(self)
        tmp=new_tmp()
        @new_stmts << Assign.new(tmp,OP_ASSIGN,rhs)
        ret.rhs=tmp
      end
      return ret
    end

  end
end
