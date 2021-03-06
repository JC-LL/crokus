require_relative 'ast'
require_relative 'cfg_printer'


module Crokus

  class ITE < Ast
    attr_accessor :cond,:trueBranch,:falseBranch
    def initialize cond,bb_t,bb_f
      @cond=cond
      @trueBranch=bb_t
      @falseBranch=bb_f
    end
  end

  class CFG
    attr_accessor :name,:bbs,:starter
    attr_accessor :infos
    def initialize name
      @name=name
      @bbs=[]
      @infos={}
      @bbs << @starter=BasicBlock.new
    end

    def each &block
      @bbs.each &block
    end

    def size
      @bbs.size
    end

    def <<(bb)
      @bbs << bb
    end

    def print versbose=false
      CFGPrinter.new.print(self,5)
    end

  end

  class BasicBlock
    @@id=-1
    attr_accessor :id,:stmts,:succs
    attr_accessor :infos
    alias :label :id

    def initialize infos={}
      @@id+=1
      @id="L"+@@id.to_s
      @stmts=[]
      @succs=[]
      @infos=infos
    end

    def <<(e)
      @stmts << e
    end

    def to bb
      @succs << bb
    end

    def trueBranch
      unless @succs.size==2
        raise "request for trueBranch failed because #{@succs.size} branch(es) found. Strange."
      end
      return @succs.first
    end

    def falseBranch
      unless @succs.size==2
        raise "request for falseBranch failed because #{@succs.size} branch(es) found. Strange."
      end
      return @succs.last
    end

    def code4dot
      @ppr||=PrettyPrinter.new
      @stmts.compact.collect{|stmt| stmt.accept(@ppr)}.join("\n")
    end

    def nextBranch
      @succs.first
    end

    def size
      @stmts.size
    end
  end
end
