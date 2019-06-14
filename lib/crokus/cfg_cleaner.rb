module Crokus

  class CFGCleaner

    def clean cfg
      puts "\t|--> cleaning '#{cfg.name}'" unless $options[:mute]
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
        cand=find_next_rec(succ)
        if cand
          #puts "  |--> #{bb.label} next #{idx} is #{cand.label}"
          @new_succs[bb] << cand
          unless @visited.include? cand
            clean_rec cand
          end
        end
      end
    end

    def find_next_rec bb
      if bb.size>0
        return bb
      else
        if bb.succs.any?
          @cfg.bbs.delete(bb)
          return find_next_rec(bb.succs.first)
        else
          return bb #ending
        end
      end
    end

    def update
      @cfg.bbs.each{|bb| bb.succs=@new_succs[bb]}
      @cfg.bbs.each{|bb|
        if (ite=bb.stmts.last).is_a? ITE
          ite.trueBranch=bb.succs.first
          ite.falseBranch=bb.succs.last
        end
      }
    end

    def rename
      @cfg.bbs.each_with_index do |bb,idx|
        bb.id="L#{idx}"
      end
    end
  end
end
