require_relative 'ast'
require_relative 'ast_printer'
require_relative 'parser'
require_relative 'parser_only'
require_relative 'visitor'
require_relative 'pretty_printer'
require_relative 'cfg_builder'

module Crokus

  class Compiler

    include Indent

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
      puts "=> compiling #{filename}" unless options[:mute]
      parse_only(filename)
      parse(filename)
      gen_dot
      #visit
      pretty_print
      build_cfg if options[:build_cfg]
      return true
    end

    def parse_only filename
      @base_name=File.basename(filename, ".c")
      code=IO.read(filename)
      indent "=> parsing #{filename}"
      @ast=parser.parse(code)
      dedent
    end

    def parse filename
      @base_name=File.basename(filename, ".c")
      code=IO.read(filename)
      indent "=> building ast #{filename}"
      @ast=Parser.new.parse(code)
      dedent
    end

    def gen_dot
      dotname="#{base_name}.dot"
      puts "=> generating dot #{dotname}" unless options[:mute]
      dot=AstPrinter.new.print(ast)
      dot.save_as dotname
      dedent
    end

    def visit
      indent "=> dummy visit" unless options[:mute]
      Visitor.new.visit(ast)
      dedent
    end

    def pretty_print
      puts "=> pretty_print" unless options[:mute]
      code=PrettyPrinter.new.visit(ast)
      pp_c=@base_name+"_pp.c"
      File.open(pp_c,'w'){|f| f.puts code}
      puts "   |--> saved as #{pp_c}" unless options[:mute]
      dedent
    end

    def build_cfg
      puts "=> building CFGs" unless options[:mute]
      builder=CFGBuilder.new
      builder.build(@ast)
    end

    def clean_cfg
      puts "=> cleaning CFGs" unless options[:mute]
      cleaner=CFGCleaner.new
      builder.clean(@ast)
    end

  end
end

if $PROGRAM_NAME == __FILE__
  filename=ARGV[0]
  t1 = Time.now
  C::Compiler.new.compile(filename)
  t2 = Time.now
  puts "parsed in     : #{t2-t1} s"
end
