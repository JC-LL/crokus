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
      elsif script=args[:random]
        compiler.execute script
      else
        puts "need a C file : crokus [options] <file.c>"
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

      parser.on("-p", "--parse", "parse only") do
        options[:parse_only]=true
      end

      parser.on("--pp", "pretty print back source code ") do
        options[:pp] = true
      end

      parser.on("--ast", "abstract syntax tree (AST)") do
        options[:ast] = true
      end

      parser.on("--cfg", "control-flow graphs for each function") do
        options[:cfg] = true
      end

      parser.on("--tac", "draw three address code (TAC) CFG") do
        options[:tac] = true
      end

      parser.on("--emit-ir", "dump textual IR from TAC CFG") do
        options[:emit_ir] = true
      end

      parser.on('--random PARAMS', "generates random c files, using parameters", String) do |params_filename|
        options[:random] = params_filename
      end

      # parser.on('--trojan PARAMS', "generates random c files, using parameters", String) do |params_filename|
      #   options[:trojan] = params_filename
      # end

      parser.on('--trojan', "generates random c files, using parameters") do
        options[:trojan] = true
      end

      parser.on("--vv", "verbose") do
        options[:verbose] = true
      end

      parser.on("-v", "--version", "Show version number") do
        puts VERSION
        exit(true)
      end

      parser.parse!(arguments)

      options[:cfile]=arguments.shift #the remaining c file

      if no_arguments
        puts parser
      end

      options
    end
  end
end
