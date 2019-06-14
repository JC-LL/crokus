require_relative 'cfg'
require_relative 'cfg_cleaner'

require_relative 'visitor'
require_relative 'cleaner'

module Crokus

  class CFGBuilder < Visitor

    def initialize
      @ind=-2
      @verbose=false
    end

    def build ast
      ast.accept(self)
    end

    def visitFunction func,args=nil
      puts "   |--> visitFunction '#{func.name}'"
      @cfg=CFG.new(func.name)
      @current=@cfg.starter
      func.body.accept(self)
      @cfg.print
      @cfg=CFGCleaner.new.clean(@cfg)
      @cfg.name=Ident.new(Token.create "#{@cfg.name}_clean")
      func.cfg=@cfg
      puts "\t|--> cfg size for '#{func.name}' : #{@cfg.size}"
      @cfg.print
    end

    def visitBody body,args=nil
      body.each do |stmt|
        case stmt
        when Assign,CtrlStmt
          stmt.accept(self)
        when Decl
        else
          @current << stmt
        end
      end
    end

    #...........stmts...............
    def  visitAssign assign,args=nil
      @current << assign
    end

    def visitReturn ret,args=nil
       @current << ret
    end

    def visitSwitch switch,args=nil
      finalBranch=BasicBlock.new
      @current_break_dest=finalBranch
      for cas in switch.cases
        cond=Binary.new(switch.expr,EQUAL,cas.expr)
        trueBranch=BasicBlock.new
        falseBranch=BasicBlock.new

        @current << ITE.new(cond,trueBranch,falseBranch)
        @current.to trueBranch
        @current.to falseBranch
        @current = trueBranch
        cas.body.accept(self)
        @current = falseBranch
      end
      if switch.default
        switch.default.accept(self)
      end
      @current=finalBranch
    end

    def visitBreak brk,args=nil
      @current << brk
      @current.to @current_break_dest
      unreachable = BasicBlock.new
      @current = unreachable
    end

    def visitContinue cont,args=nil
      raise " NIY : continue"
    end

    def visitIf if_,args=nil
      cond=if_.cond.accept(self)
      @cfg << trueBranch =BasicBlock.new
      @cfg << falseBranch=BasicBlock.new
      @cfg << mergeBranch=BasicBlock.new
      @current << ITE.new(cond,trueBranch,falseBranch)
      @current.to trueBranch
      @current.to falseBranch
      #-----------
      @current=trueBranch
      if_.body.accept(self) #may change @current !
      @current.to mergeBranch
      #
      @current=falseBranch
      if_.else.accept(self) if if_.else #may change @current !
      @current.to mergeBranch
      @current=mergeBranch
    end

    def visitElse else_,args=nil
      else_.body.accept(self)
    end

    def visitWhile while_,args=nil
      cond=while_.cond.accept(self)
      @cfg << cond_bb     = BasicBlock.new
      @cfg << trueBranch  = BasicBlock.new
      @cfg << falseBranch = BasicBlock.new
      @current.to cond_bb
      cond_bb << ITE.new(cond,trueBranch,falseBranch)
      cond_bb.to trueBranch
      cond_bb.to falseBranch
      @current = trueBranch
      while_.body.accept(self) #may modify identity of @current
      @current.to cond_bb
      @current=falseBranch
    end

    def visitFor for_,args=nil
      for_.init.each{|stmt| stmt.accept(self)}
      cond=for_.cond.accept(self)
      @cfg << cond_bb     = BasicBlock.new
      @cfg << trueBranch  = BasicBlock.new
      @cfg << falseBranch = BasicBlock.new
      @current_break_dest=falseBranch
      @current.to cond_bb
      cond_bb << ITE.new(cond,trueBranch,falseBranch)
      cond_bb.to trueBranch
      cond_bb.to falseBranch
      @current= trueBranch
      for_.body.accept(self) #may modify @current identity
      for_.increment.accept(self)
      @current.to cond_bb
      @current=falseBranch
    end


    #..........expresions..........

    # def visitFunCall fcall,args=nil
    #   @current << fcall
    # end
    #
    # def visitParenth par,args=nil
    #   par.expr.accept(self)
    # end
    #
    # def visitBinary expr,args=nil
    #   expr.lhs.accept(self)
    #   expr.op.accept(self)
    #   expr.rhs.accept(self)
    #   expr
    # end

  end #class Visitor
end #module