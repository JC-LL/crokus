module Crokus

  class IRDumper < Visitor

    def visitFunction func,args=nil
      puts "IR for '#{func.name}'".center(40,'=')
      dump func.cfg
    end

    def dump cfg
      @visited=[]
      visit_rec cfg.starter
    end

    def visit_rec bb
      print bb.label+":"
      @visited << bb
      @current=bb
      bb.stmts.each do |stmt|
        puts "\t"+stmt.str.gsub(/;/,'')
      end
      unless bb.stmts.last.is_a? Crokus::ITE
        if bb.succs.any?
          puts "\tgoto #{bb.succs.first.label}"
        end
      end
      if bb.succs.empty?
        puts "\tstop"
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
      "\t"+"ite #{cond},#{label1},#{label2}"
    end

  end
end
