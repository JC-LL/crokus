require_relative 'ast'
require_relative 'parser'
require_relative 'dot_printer_rec'
require_relative 'visitor'
require_relative 'pretty_printer'

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
      puts "Crokus - (c) JC Le Lann 2016-20" unless options[:mute]
    end

    def verbose
      @options[:verbose]
    end

    def compile filename
      header
      puts "=> compiling #{filename}" unless options[:mute]
      parse(filename)
      gen_dot
      visit
      pretty_print
      return true
    end

    def parse filename
      @base_name=File.basename(filename, ".c")
      code=IO.read(filename)
      indent "=> parsing #{filename}"
      @ast=parser.parse(code)
      dedent
    end

    def gen_dot
      dotname="#{base_name}.dot"
      indent "=> generating dot #{dotname}" unless options[:mute]
      dot=DotPrinter.new.print(ast)
      dot.save_as dotname
      dedent
    end

    def visit
      indent "=> dummy visit" unless options[:mute]
      Visitor.new.visit(ast)
      dedent
    end

    def pretty_print
      indent "=> pretty_print" unless options[:mute]
      code=PrettyPrinter.new.visit(ast)
      #puts code.finalize
      pp_c=@base_name+"_pp.c"
      filename=code.save_as pp_c
      puts "...saved as #{filename}" unless options[:mute]
      dedent
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
