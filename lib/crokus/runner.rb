require "optparse"

require_relative "compiler"

module Crokus

  class Runner

    def self.run *arguments
      new.run(arguments)
    end

    def run arguments
      compiler=Compiler.new
      compiler.options = args = parse_options(arguments)
      if filename=args[:cfile]
        compiler.compile filename
      else
        puts "need a C file : crokus -c <file.c>"
      end
    end

    def header
      puts "Crokus (#{VERSION})- (c) JC Le Lann 2016-20"
    end

    private
    def parse_options(arguments)
      header

      parser = OptionParser.new

      no_arguments=arguments.empty?

      options = {}

      parser.on("-h", "--help", "Show help message") do
        puts parser
        exit(true)
      end

      parser.on("--pp", "pretty print back source code ") do
        options[:pp] = true
      end

      parser.on("--ast", "draw abstract syntax tree (AST)") do
        options[:draw_ast] = true
      end

      parser.on("--cfg", "draw control-flow graphs for each function") do
        options[:draw_cfg] = true
      end

      parser.on("--tac", "draw three address code (TAC) CFG") do
        options[:draw_cfg_tac] = true
      end

      parser.on("--emit-ir", "dump textual IR from TAC CFG") do
        options[:emit_ir] = true
      end

      parser.on("-v", "--version", "Show version number") do
        puts VERSION
        exit(true)
      end

      parser.on("-c FILE", "source file") do |file|
        options[:cfile] = file
      end

      parser.parse!(arguments)

      if no_arguments
        puts parser
      end

      options
    end
  end
end
