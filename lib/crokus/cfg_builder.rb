require_relative 'cfg'
require_relative 'cfg_cleaner'

require_relative 'visitor'
require_relative 'cleaner'

module Crokus

  class CFGBuilder < Transformer

    def initialize
      @ind=-2
      @verbose=false
    end

    def build ast
      ast.accept(self)
    end

    def visitFunction func,args=nil
      puts " |--[+] visitFunction '#{func.name}'" unless $options[:mute]
      @cfg=CFG.new(func.name)
      @current=@cfg.starter
      func.body.accept(self)
      @cfg.print
      @cfg=CFGCleaner.new.clean(@cfg)
      @cfg.name=Ident.new(Token.create "#{@cfg.name}_clean")
      func.cfg=@cfg
      puts " "*5+"|--[+] cfg size for '#{func.name}' : #{@cfg.size}" unless $options[:mute]
      @cfg.print
    end

    def visitBody body,args=nil
      body.each{|stmt| stmt.accept(self,args)}
    end
    #...........stmts...............
    def visitAssign assign,args=nil
      @current << assign
    end

    def visitLabeledStmt assign,args=nil
      @current << assign
    end

    def visitPreFixAccu accu,args=nil
      @current << accu
    end

    def visitPostFixAccu accu,args=nil
      @current << accu
    end

    def visitSwitch switch,args=nil
      @cfg << finalBranch=BasicBlock.new
      @current_break_dest=finalBranch
      for cas in switch.cases
        cond=Binary.new(switch.expr,EQUAL,cas.expr)
        @cfg << trueBranch=BasicBlock.new
        @cfg << falseBranch=BasicBlock.new

        @current << ITE.new(cond,trueBranch,falseBranch)
        @current.to trueBranch
        @current.to falseBranch
        @current = trueBranch
        cas.body.accept(self)
        @current = falseBranch
      end
      if switch.default
        switch.default.accept(self)
        @current.to finalBranch
      end
      @current=finalBranch
    end

    def visitBreak brk,args=nil
      @current << brk
      @current.to @current_break_dest
      @cfg << unreachable = BasicBlock.new
      @current = unreachable
    end

    def visitContinue cont,args=nil
      @current << cont
      @current.to @current_continue_dest
      @cfg << unreachable = BasicBlock.new
      @current = unreachable
    end

    def visitIf if_,args=nil
      cond=if_.cond.accept(self,:as_expr)
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
      cond=while_.cond.accept(self,:as_expr)
      @cfg << cond_bb     = BasicBlock.new
      @current_cond = cond_bb # for continue stmt !
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
      @cfg << postBranch  = BasicBlock.new
      @current_continue_dest = postBranch
      @current_break_dest    = falseBranch
      @current.to cond_bb
      cond_bb << ITE.new(cond,trueBranch,falseBranch)
      cond_bb.to trueBranch
      cond_bb.to falseBranch
      @current= trueBranch
      for_.body.accept(self) #may modify @current identity
      @current.to postBranch
      @current=postBranch
      for_.increment.accept(self)
      @current.to cond_bb
      @current=falseBranch
    end

    def visitDoWhile dowhile,args=nil
      @cfg << cond_bb     = BasicBlock.new
      @current_continue_dest = cond_bb # for continue stmt !
      @cfg << trueBranch  = BasicBlock.new
      @cfg << falseBranch = BasicBlock.new

      @current.to trueBranch
      @current = trueBranch
      dowhile.body.accept(self) # may modify @current

      @current.to cond_bb
      @current = cond_bb
      cond=dowhile.cond.accept(self)

      cond_bb << ITE.new(cond,trueBranch,falseBranch)

      cond_bb.to trueBranch
      cond_bb.to falseBranch
      @current = falseBranch
    end

  end #class Visitor
end #module
