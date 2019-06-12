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

    private
    def parse_options(arguments)

      size=arguments.size

      parser = OptionParser.new

      options = {}

      parser.on("-h", "--help", "Show help message") do
        puts parser
        exit(true)
      end

      parser.on("-v", "--version", "Show version number") do
        puts VERSION
        exit(true)
      end

      parser.on("--cfg", "build cfg") do
        options[:build_cfg] = true
      end

      parser.on("-c FILE", "source file>") do |file|
        options[:cfile] = file
      end

      parser.parse!(arguments)

      if size==0
        puts parser
      end

      options
    end
  end
end
