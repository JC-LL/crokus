require_relative 'ast'
require_relative 'ast_printer'
require_relative 'parser'
require_relative 'visitor'
require_relative 'pretty_printer'
require_relative 'trojan_inserter'

require_relative 'cfg_builder'
require_relative 'cfg_printer_only_dot'
require_relative 'cfg_printer_only_json'
require_relative 'cfg_line_printer'
require_relative 'tac_builder'
require_relative 'ir_dumper'
require_relative 'cfg_random_gen' # random C generation

module Crokus

  class Compiler
    attr_accessor :options
    attr_accessor :parser
    attr_accessor :ast
    attr_accessor :base_name

    def initialize
      @options={}
      $options=@options
      @parser=Parser.new
    end

    def compile filename
      parse(filename)
      return true if options[:parse_only]

      draw_ast(@ast) if options[:ast]

      build_cfg
      return true if options[:cfg]

      if options[:print_cfg_dot]
        print_cfg_only(:dot)
        return true
      end

      if options[:print_cfg_json]
        print_cfg_only(:json)
        return true
      end

      pretty_print

      if options[:show_lines]
        show_lines()
      end

      if options[:trojan]
        return_code=insert_trojan()
        return return_code
      end

      build_tac
      return true if options[:tac]

      emit_ir
      return true
    end

    def parse filename
      @base_name=File.basename(filename, ".c")
      code=IO.read(filename)
      puts "[+] parsing #{filename}" unless options[:mute]
      @ast=Parser.new.parse(code)
      draw_ast     if options[:draw_ast]
      pretty_print if options[:pp]
    end

    def draw_ast tree=nil,filename=nil
      dotname=filename || "#{base_name}_ast.dot"
      puts "   |--[+] drawing AST '#{dotname}'" unless options[:mute]
      ast_ = tree || @ast
      dot=AstPrinter.new.print(ast_)
      dot.save_as dotname
    end

    def transform
      puts "[+] dummy transform" unless options[:mute]
      ast_t= Transformer.new.transform(ast)
      dotname="#{base_name}_trans.dot"
      draw_ast ast_t,dotname
    end

    def visit
      puts "[+] dummy visit" unless options[:mute]
      Visitor.new.visit(ast)
    end

    def pretty_print
      puts "[+] pretty_print" unless options[:mute]
      code=PrettyPrinter.new.visit(ast)
      pp_c=@base_name+"_pp.c"
      File.open(pp_c,'w'){|f| f.puts code}
      puts " "*1+"|--[+] saved as #{pp_c}" unless options[:mute]
    end

    def build_cfg
      puts "[+] building CFGs" unless options[:mute]
      builder=CFGBuilder.new
      builder.build(ast)
    end

    def build_tac
      puts "[+] building TAC" unless options[:mute]
      builder=TACBuilder.new
      builder.visit(ast)
    end

    def emit_ir
      puts "[+] emit textual IR " unless options[:mute]
      IRDumper.new.visit(ast)
    end

    def print_cfg_only format
      puts "[+] print textual CFG only format #{format}" unless options[:mute]
      case format
      when :dot
        CFGOnlyPrinterDot.new.visit(ast)
      when :json
        CFGOnlyPrinterJson.new.visit(ast)
      end
    end

    def execute params
      RandomGen.new.run(params)
    end

    def insert_trojan
      puts "[+] inserting trojan" unless options[:mute]
      infected_ast=TrojanInserter.new(@options).insert(ast)
      if infected_ast
        code=PrettyPrinter.new.visit(infected_ast)
        pp_c=@base_name+"_troj.c"
        File.open(pp_c,'w'){|f| f.puts code}
        puts " "*5+"|--> saved as #{pp_c}" unless options[:mute]
        return true
      else
        return false
      end
    end

    def show_lines
      puts "[+] showing labels/lines mapping" unless options[:mute]
      CFGLinePrinter.new.visit(@ast)
    end

  end
end
