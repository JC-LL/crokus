module Crokus

  class IRDumper < Visitor

    def visitFunction func,args=nil
      puts " "*1+"|--[+] IR for '#{func.name}'"
      ir_code=dump(func.cfg)
      filename=func.name.to_s+".ir"
      ir_code.save_as filename
      puts " "*5+"|--[+] generated #{filename}"
    end

    def dump cfg
      @visited=[]
      @code=Code.new
      visit_rec cfg.starter
      return @code
    end

    def visit_rec bb
      @code << bb.label+":"
      @visited << bb
      @current=bb
      bb.stmts.each do |stmt|
        unless stmt.is_a? Break or stmt.is_a? Continue
          @code << "\t"+stmt.str.gsub(/;/,'')
        end
      end
      unless bb.stmts.last.is_a? Crokus::ITE
        if bb.succs.any?
          @code << "\tgoto #{bb.succs.first.label}"
        end
      end
      if bb.succs.empty?
        @code << "\tstop"
      else
        bb.succs.each do |bb|
          unless @visited.include? bb
            visit_rec(bb)
          end
        end
      end
    end

    def visitITE ite,args=nil
      cond=ite.cond.accept(self)
      label1=ite.trueBranch.label
      label2=ite.falseBranch.label
      @code << "\t"+"ite #{cond},#{label1},#{label2}"
    end

  end
end
