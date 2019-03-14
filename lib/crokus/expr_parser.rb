require 'pp'

require_relative 'lexer'
require_relative 'ast'

module Crokus

  class ExprParser

    attr_accessor :tokens,:str

    def initialize
      @ind=0
    end

    def indent str=nil
      @ind+=2
      puts " "*@ind+str if str
    end

    def dedent
      @ind-=2
    end

    def acceptIt
      say showNext.kind.to_s+" "+showNext.val
      tokens.shift
    end

    def maybe kind
      return acceptIt if showNext.is_a? kind
    end

    def say str
      puts " "*@ind+str.to_s
    end

    def expect kind
      if ((actual=tokens.shift).kind)!=kind
        puts "ERROR :"
        show_line(actual.pos)
        raise "expecting '#{kind}'. Received '#{actual.val}' around #{actual.pos}"
      end
      say actual.kind.to_s+" "+actual.val
      return actual
    end

    def showNext(n=1)
      tokens[n-1]
    end

    def show_line pos
      l,c=*pos
      show_lines(str,l-2)
      line=str.split(/\n/)[l-1]
      pointer="-"*(5+c)+ "^"
      puts "#{l.to_s.ljust(5)}|#{line}"
      puts pointer
    end

    #............ parsing methods ...........
    def parse str
      @str=str
      @tokens=CLexer.new.tokenize(str)
      pp @tokens
      while tokens.any?
        ast=expression()
        expect :semicolon
      end
    end

  def expression
    indent "expression...starting by '#{showNext.val}'"

    lhs=factor()
    while showNext.is_a? [:add,:sub,:eq,:neq,:lt,:lte,:dbar]
      op=acceptIt
      rhs=factor()
    end
    dedent
  end

  def factor
    indent "factor"
    ret=[]
    ret << term()
    multiplicative_operators = [:mul, :div,:gt,:gte,:assign]
    while showNext.is_a? [:mul, :div,:gt,:gte,:assign]
      ret << acceptIt
      if showNext.is_a? :rparen
        # casting (float *)
        return
      end
      ret << term()
    end
    ret
    dedent
  end

  def next_is_operator
    operators=[:add,:sub,:gt,:gte,:lt,:lte,:div]
    operators.include?(showNext.kind)
  end

  def term
    indent "term...starting by '#{showNext.val}'"
    case showNext.kind
    when :add,:sub
      acceptIt
      expression
    when :mul #dereference
      acceptIt
      expression
    when :lparen
      acceptIt
      expression
      expect :rparen
      # we can be there, at 'a' : (float *) a
      unless next_is_operator or showNext.is_a? :semicolon
        term
      end
    when :ampersand,:ident
      addressof?
      expect :ident
      while showNext.is_a? [:lbrack,:lparen,:dot]
        parenthesized?
        indexed?
        doted?
      end
    when :integer_literal,:float_literal,:string_lit,:char_lit
      acceptIt
    else
      raise "unknown term of kind #{showNext.kind}"
    end
    dedent
  end


  def addressof?
    if showNext.is_a? :ampersand
      acceptIt
    else
      return false
    end
  end

  def indexed?
    if showNext.is_a? :lbrack
      acceptIt
      expression
      expect :rbrack
    else
      return false
    end
  end

  def parenthesized?
    if showNext.is_a? :lparen
      acceptIt
      expression
      while showNext.is_a? :comma
        acceptIt
        expression
      end
      expect :rparen
    else
      return false
    end
  end

  def doted?
    if showNext.is_a? :dot
      acceptIt
      expect :ident
    else
      false
    end
  end
end

end #module

def show_lines str,upto=nil
  lines=str.split(/\n/)
  upto=upto || lines.size
  lines[0..upto].each_with_index do |line,idx|
    puts "#{(idx+1).to_s.ljust(5)}|#{line}"
  end
end

if $PROGRAM_NAME == __FILE__
  str=IO.read(ARGV[0])
  show_lines(str)
  t1 = Time.now
  parser=C::ExprParser.new
  ast=parser.parse(str)
  pp ast
  t2 = Time.now
  puts "parsed in     : #{t2-t1} s"
end
