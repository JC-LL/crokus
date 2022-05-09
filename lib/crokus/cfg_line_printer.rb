module Crokus

  class CFGLinePrinter < Visitor

    def visitFunction func,args=nil
      @visited=[]
      visit_rec(func.cfg.starter)
    end

    def visit_rec bb
      puts "label : #{bb.label}"
      @visited << bb
      lines=bb.stmts.select{|stmt| stmt.is_a? Assign}.map do |stmt|
        get_pos(stmt.rhs)
      end
      lines.flatten!
      pp lines.minmax if lines.any?
      bb.succs.each do |succ|
        unless @visited.include? succ
          visit_rec(succ)
        end
      end
    end

    def get_pos expr
      lines=[]
      case expr
      when Binary
        lines << get_pos(expr.rhs)
        lines << get_pos(expr.lhs)
      when Unary
        lines << get_pos(expr.rhs)
      when Ident,IntLit
        if line=expr.tok.pos.first
          lines << line
        end
      end
      return lines
    end
  end
end
