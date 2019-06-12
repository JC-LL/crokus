module Crokus

  class CFGCleaner

    def clean cfg
      puts "\t|--> cleaning '#{cfg.name}'"
      @cfg=cfg
      @visited=[]
      @new_succs={}
      clean_rec cfg.starter
      update
      rename
      cfg
    end

    private

    def clean_rec bb
      @visited << bb
      @new_succs[bb]=[]
      bb.succs.each_with_index do |succ,idx|
        cand=find_non_empty_rec(succ)
        @new_succs[bb] << cand
        unless @visited.include? cand
          clean_rec cand
        end
      end
    end

    def find_non_empty_rec bb
      if bb.size>0
        return bb
      else
        @cfg.bbs.delete(bb)
        return find_non_empty_rec(bb.succs.first)
      end
    end

    def update
      @cfg.bbs.each do |bb|
        bb.succs=@new_succs[bb]
      end
    end

    def rename
      @cfg.bbs.each_with_index do |bb,idx|
        bb.id="L#{idx}"
      end
    end
  end
end
