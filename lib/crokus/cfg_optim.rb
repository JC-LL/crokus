module Crokus

  class CFGOptimizer

    def clean cfg
      puts " "*5+"|--[+] optimizing '#{cfg.name}'" unless $options[:mute]
      @cfg=cfg
      @visited=[]
      @new_succs={}
      optim_rec cfg.starter
      cfg
    end

    private

    def optim_rec bb
      @visited << bb
      @new_succs[bb]=[]
      bb.succs.each_with_index do |succ,idx|
        if bb.succs.size==1 and succ.succs.size==1
          bb.stmts << succ.stmts
          bb.stmts.flatten!
          @cfg.bbs.delete(succ)
          bb.succs[0]=succ.succs.first
        end
        optim_rec succ unless @visited.include?(succ)
      end
    end

  end
end
