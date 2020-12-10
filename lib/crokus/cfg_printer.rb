require_relative 'code'

module Crokus

  class CFGPrinter

    attr_accessor :code

    def print cfg,pos=0
      @code=Code.new
      @code << header
      @visited=[]
      visitRec(cfg.starter)
      @code << footer
      dot_name="cfg_#{cfg.name}.dot"
      @code.save_as dot_name
      puts " "*pos+"|--[+] graphviz file saved as '#{dot_name}'"
    end

    def header
      ret=Code.new
      ret << "digraph ControlFlowGraph {"
      ret.indent=2
      ret << 'forcelabels=true;'
      ret << 'graph [ label="",'
      ret << '        bgcolor="white",'
      ret << '        fontname="Arail",'
      ret << '        rankdir="TB"]'
      ret.newline
      ret << 'node  [ fontname="Arial",'
      ret << '            shape="box",'
      ret << '            style="filled",'
      ret << '            fillcolor="AliceBlue"]'
      ret.newline
      ret << 'edge  [ fontname="Arial",'
      ret << '        color="Blue",'
      ret << '        dir="forward"]'
      ret.newline
      ret
    end

    def footer
      "}"
    end

    def visitRec bb
      while !@visited.include?(bb)
        @visited << bb
        c_code=bb.code4dot
        #puts c_code
        c_code=clean4dot(c_code)
        code << "#{id(bb)} [label=\"#{c_code}\",shape=rectangle, xlabel=#{bb.label}]"
        bb.succs.each_with_index do |succ,idx|
          if bb.succs.size>1
            label = (idx==0 ? "true" : "false")
            label = "[label=#{label}]"
          end
          code << "#{id(bb)} -> #{id(succ)} #{label}"
          visitRec(succ)
        end
      end
    end

    def id bb
      "bb_#{bb.id.to_s}"
    end

    def clean4dot str
      str=str.gsub(/\\n\"/,'"')
      str=str.gsub(/"/,'\"')
    end

  end
end
