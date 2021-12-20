module Crokus

  class CFGOnlyPrinter < Visitor

    def visitFunction func,format
      puts " "*1+"|--[+] print CFG for '#{func.name}'"
      ir_code=dump(func.cfg)
      format=ir_code.lines.first.start_with?("digraph") ? "dot" : "json"
      filename=func.name.to_s+".#{format}"
      ir_code.save_as filename
      puts " "*5+"|--[+] generated #{filename}"
    end

    def dump cfg
      @visited=[]
      @code=Code.new
      header
      visit_rec(cfg.starter)
      footer
      return @code
    end

  end
end
