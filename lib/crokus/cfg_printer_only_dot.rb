require_relative "cfg_printer_only"

module Crokus

  class CFGOnlyPrinterDot < CFGOnlyPrinter

    def header
      @code << "digraph ControlFlowGraph {"
      @code.indent=2
      @code << "forcelabels=true;"
      @code << "graph [ label=\"\","
      @code << "        bgcolor=\"white\","
      @code << "        fontname=\"Arial\","
      @code << "        rankdir=\"TB\"]"
      @code.newline
      @code << "node  [ fontname=\"Arial\","
      @code << "        shape=\"box\","
      @code << "        style=\"filled\","
      @code << "        fillcolor=\"AliceBlue\"]"
      @code.newline
      @code << "edge  [ fontname=\"Arial\","
      @code << "        color=\"Blue\","
      @code << "        dir=\"forward\"]"
    end

    def visit_rec bb
      @visited << bb
      @code << "bb_#{bb.label} [label=\"\",shape=rectangle, xlabel=#{bb.label}]"
      @current=bb
      if (ite=bb.stmts.last).is_a? ITE

        unless @visited.include? (bb_t=ite.trueBranch)
            visit_rec(bb_t)
        end
        unless @visited.include? (bb_f=ite.falseBranch)
            visit_rec(bb_f)
        end
        @code << "bb_#{bb.label} -> bb_#{(bb_t=ite.trueBranch).label} [label=\"T\"]"
        @code << "bb_#{bb.label} -> bb_#{(bb_f=ite.falseBranch).label} [label=\"F\"]"
      else
        bb.succs.each do |succ|
          unless @visited.include? succ
            visit_rec(succ)
          end
          @code << "bb_#{bb.label} -> bb_#{succ.label}"
        end
      end
    end

    def footer
      @code << "}"
    end
  end
end
