require_relative 'ast'
require_relative 'ast_printer'
require_relative 'parser'
require_relative 'parser_only'
require_relative 'visitor'
require_relative 'transformer'
require_relative 'pretty_printer'
require_relative 'cfg_builder'
require_relative 'tac_builder'
require_relative 'ir_dumper'

module Crokus

  class Compiler

    attr_accessor :options
    attr_accessor :parser
    attr_accessor :ast
    attr_accessor :base_name

    def initialize
      @options={}
      @parser=Parser.new
    end

    def header
      puts "Crokus (#{VERSION})- (c) JC Le Lann 2016-20" unless options[:mute]
    end

    def compile filename
      header
      @verbose=@options[:verbose] #ugly
      parse_only(filename)
      parse(filename)
      gen_dot
      #visit
      transform
      pretty_print
      build_cfg if options[:build_cfg]
      build_tac if options[:build_tac]
      emit_ir   if options[:emit_ir]
      return true
    end

    def parse_only filename
      @base_name=File.basename(filename, ".c")
      code=IO.read(filename)
      puts "=> parsing #{filename}" unless options[:mute]
      @ast=parser.parse(code)
    end

    def parse filename
      @base_name=File.basename(filename, ".c")
      code=IO.read(filename)
      @ast=Parser.new.parse(code)
    end

    def gen_dot tree=nil,filename=nil
      dotname=filename || "#{base_name}.dot"
      puts "   |--> generating dot #{dotname}" unless options[:mute]
      ast_ = tree || @ast
      dot=AstPrinter.new.print(ast_)
      dot.save_as dotname
    end

    def transform
      puts "=> dummy transform"
      ast_t= Transformer.new.transform(ast)
      dotname="#{base_name}_trans.dot"
      gen_dot ast_t,dotname
    end

    def visit
      puts "=> dummy visit" unless options[:mute]
      Visitor.new.visit(ast)
    end

    def pretty_print
      puts "=> pretty_print" unless options[:mute]
      code=PrettyPrinter.new.visit(ast)
      pp_c=@base_name+"_pp.c"
      File.open(pp_c,'w'){|f| f.puts code}
      puts "   |--> saved as #{pp_c}" unless options[:mute]
    end

    def build_cfg
      puts "=> building CFGs" unless options[:mute]
      builder=CFGBuilder.new
      builder.build(@ast)
    end

    def build_tac
      puts "=> building TAC" unless options[:mute]
      builder=TACBuilder.new
      builder.visit(@ast)
    end

    def emit_ir
      puts "=> emit textual IR " unless options[:mute]
      IRDumper.new.visit(@ast)
    end

  end
end
#
# if $PROGRAM_NAME == __FILE__
#   filename=ARGV[0]
#   t1 = Time.now
#   C::Compiler.new.compile(filename)
#   t2 = Time.now
#   puts "parsed in     : #{t2-t1} s"
# end
