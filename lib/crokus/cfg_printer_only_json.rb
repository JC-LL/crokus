require_relative "cfg_printer_only"

module Crokus

  class CFGOnlyPrinterJson < CFGOnlyPrinter

    def header
      @code << "{"
      @code.indent=2
    end

    def visit_rec bb
      @visited << bb
      @current=bb
      if (ite=bb.stmts.last).is_a? ITE
        @code << "\"#{bb.label}\": {"
        @code.indent=4
        @code << "\"true\":  \"#{(bb_t=ite.trueBranch).label}\""
        @code << "\"false\": \"#{(bb_f=ite.falseBranch).label}\""
        @code.indent=2
        @code << "}"
        unless @visited.include? bb_t
            visit_rec(bb_t)
        end
        unless @visited.include? bb_t
            visit_rec(bb_t)
        end
      else
        bb.succs.each do |succ|
          @code << "\"#{bb.label}\": \"#{succ.label}\""
          unless @visited.include? succ
            visit_rec(succ)
          end
        end
      end
    end

    def footer
      @code.indent=0
      @code << "}"
    end

  end

end
