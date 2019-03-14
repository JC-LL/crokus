require 'pp'

require_relative 'generic_lexer'

module Crokus
  class Lexer < GenericLexer

    def initialize
      super
      ignore /\s+/

      keyword 'for'
      keyword 'if'
      keyword 'else'
      keyword 'break'
      keyword 'while'
      keyword 'return'
      keyword 'struct'
      keyword 'typedef'
      keyword 'sizeof'
      keyword 'switch'
      keyword 'case'
      keyword 'default'
      keyword 'do'
      keyword 'void'
      keyword 'goto'

      keyword 'int'
      keyword 'char'
      keyword 'short'
      keyword 'long'
      keyword 'float'
      keyword 'double'
      keyword 'signed'
      keyword 'unsigned'

      token :lparen             , /\(/
      token :rparen             , /\)/
      token :lbrace             , /\{/
      token :rbrace             , /\}/
      token :lbrack             , /\[/
      token :rbrack             , /\]/
      token :semicolon          , /;/
      token :colon              , /:/
      token :comma              , /\,/
      token :lcomment           , /\/\*/
      token :rcomment           , /\*\//
      token :comment            , /\/\/(.*)/

      token :dot                , /\./
      token :neq                , /!=/
      token :not                , /\!/
      token :eq                 , /\=\=/
      token :assign             , /\=/
      token :addadd             , /\+\+/
      token :addeq              , /\+\=/
      token :add                , /\+/
      token :subsub             , /\-\-/
      token :subeq              , /\-\=/
      token :arrow              , /\-\>/
      token :sub                , /\-/
      token :muleq              , /\*=/
      token :mul                , /\*/
      token :diveq              , /\/=/
      token :div                , /\//

      token :dbar               , /\|\|/
      token :lte                , /<=/
      token :lt                 , /</
      token :gte                , />=/
      token :gt                 , />/
      token :ampersand2         , /&&/
      token :ampersand          , /\&/
      token :or                 , /\|/
      token :modeq              , /\%=/
      token :mod                , /\%/
      token :sharp              , /#/


      # .............literals.........................
      token :ident              , /\A[a-zA-Z]\w*/i
      token :float_lit          , /\d*(\.\d+)(E([+-]?)\d+)?/
      token :integer_lit        , /\A\d+/
      token :string_lit         , /"[^"]*"/
      token :char_lit           , /\A'\\?.'/
      token :selected_name      , /\w+(\.\w+)+/ # /\S+\w+\.\w+/
      token :based_lit          , /\d+#\w+(\.\w+)?#(E[+-]?\d+)/
      token :bit_string_lit     , /(b|o|x)"[^_]\w+"/
      token :lexer_warning      , /./
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
