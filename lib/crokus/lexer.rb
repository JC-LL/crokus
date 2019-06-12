require_relative 'generic_lexer'

module Crokus
  class Lexer < GenericLexer

    def initialize
      super
      ignore /\s+/
      keyword "auto"
      keyword "break"
      keyword "case"
      keyword "char"
      keyword "const"
      keyword "continue"
      keyword "default"
      keyword "do"
      keyword "double"
      keyword "else"
      keyword "enum"
      keyword "extern"
      keyword "float"
      keyword "for"
      keyword "goto"
      keyword "if"
      keyword "int"
      keyword "long"
      keyword "register"
      keyword "return"
      keyword "short"
      keyword "signed"
      keyword "sizeof"
      keyword "static"
      keyword "struct"
      keyword "switch"
      keyword "typedef"
      keyword "union"
      keyword "unsigned"
      keyword "void"
      keyword "volatile"
      keyword "while"

      token :qmark            => /\?/
      token :lparen           => /\(/
      token :rparen           => /\)/
      token :lbrace           => /\{/
      token :rbrace           => /\}/
      token :lbrack           => /\[/
      token :rbrack           => /\]/
      token :semicolon        => /;/
      token :colon            => /:/
      token :comma            => /\,/
      token :lcomment         => /\/\*/
      token :rcomment         => /\*\//
      token :comment          => /\/\/(.*)/

      token :dot              => /\./
      token :neq              => /!=/
      token :not              => /\!/
      token :eq               => /\=\=/
      token :assign           => /\=/
      token :inc_op           => /\+\+/
      token :add_assign       => /\+\=/
      token :add              => /\+/
      token :dec_op           => /\-\-/
      token :sub_assign       => /\-\=/
      token :ptr_op           => /\-\>/
      token :sub              => /\-/
      token :mul_assign       => /\*=/
      token :mul              => /\*/
      token :div_assign       => /\/=/
      token :div              => /\//

      token :shift_r          => /\>\>/
      token :shift_l          => /\<\</
      token :oror             => /\|\|/
      token :lte              => /<=/
      token :lt               => /</
      token :gte              => />=/
      token :gt               => />/
      token :andand           => /\&\&/
      token :and              => /\&/
      token :or               => /\|/
      token :mod_assign       => /\%=/
      token :mod              => /\%/
      token :xor_assign       => /\^\=/
      token :xor              => /\^/

      token :sharp            => /#/

      # .............literals..............................

      token :ident            => /\A[a-zA-Z]\w*/i
      token :float_lit        => /\A\d*(\.\d+)(E([+-]?)\d+)?/
      token :integer_lit      => /\A(0x[0-9a-fA-F]+)|\d+/
      token :string_lit       => /\A"[^"]*"/
      token :char_lit         => /\A'\\?.'/
      token :lexer_warning    => /./

    end
  end
end

if $PROGRAM_NAME == __FILE__
  str=IO.read(ARGV[0])
  puts str
  t1 = Time.now
  lexer=Crokus::Lexer.new
  tokens=lexer.tokenize(str)
  t2 = Time.now
  pp tokens
  puts "number of tokens : #{tokens.size}"
  puts "tokenized in     : #{t2-t1} s"
end
