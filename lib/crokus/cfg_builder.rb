
require_relative 'code'
require_relative 'cfg'
require_relative 'cfg_cleaner'

require_relative 'visitor'
require_relative 'cleaner'

module Crokus

  class CFGBuilder < Visitor

    include Indent
    attr_accessor :code

    def initialize
      @ind=-2
      @verbose=false
    end

    def build ast
      ast.accept(self)
    end

    def visitDesignUnit du,args=nil
      indent "DesignUnit"
      du.list.each{|e| e.accept(self,:body)}
      dedent
    end

    def visitFunction func,args=nil
      puts "   |--> visitFunction '#{func.name}'"
      @cfg=CFG.new(func.name)
      @current=@cfg.starter
      func.body.accept(self)
      @cfg=CFGCleaner.new.clean(@cfg)
      func.cfg=@cfg
      puts "\t|--> cfg size for '#{func.name}' : #{@cfg.size}"
      @cfg.print
    end

    #...........stmts...............
    def visitCommaStmt stmt,args=nil
    end

    def visitDecl decl,args=nil
    end

    def visitAssign assign,args=nil
      lhs=assign.lhs.accept(self)
      op =assign.op.accept(self)
      rhs=assign.rhs.accept(self)
      @current << assign
    end

    def visitAccu accu,args=nil
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op =accu.op.accept(self)
      rhs=accu.rhs.accept(self) if accu.rhs # i++
      @current << ret
    end

    def visitPostFixAccu accu,args=nil
      lhs=accu.lhs.accept(self) if accu.lhs #++i
      op =accu.op.accept(self)
      @current << accu
    end

    def visitFunCall fcall,args=nil
      fname=fcall.name.accept(self)
      argus=fcall.args.collect{|argu| argu.accept(self)}
      argus=argus.join(',')
      @current << fcall
    end

    def visitReturn ret,args=nil
      ret
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
      if_.else.accept(self) #may change @current !
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

    def visitBody body,args=nil
      body.each{|stmt| stmt.accept(self)}
    end
    #..........expresions..........

    def visitFunCall fcall,args=nil
      @current << fcall
    end

    def visitParenth par,args=nil
      par.expr.accept(self)
    end

    def visitBinary expr,args=nil
      expr.lhs.accept(self)
      expr.op.accept(self)
      expr.rhs.accept(self)
      expr
    end

  end #class Visitor
end #module
