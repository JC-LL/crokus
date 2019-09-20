require_relative "./lib/crokus/version"

Gem::Specification.new do |s|
  s.name        = 'crokus'
  s.version     = Crokus::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "Simple parser for a large subset of C language, for experimental purposes"
  s.description = "Crokus is developped in Ruby and aims at providing simple basis for C transformations. It has been use for teaching purposes and applied to Electronic System Level experiments."
  s.authors     = ["Jean-Christophe Le Lann"]
  s.email       = 'lelannje@ensta-bretagne.fr'

  s.files       = [
                    "lib/crokus/ast_printer.rb",
                    "lib/crokus/ast.rb",
                    "lib/crokus/cfg_builder.rb",
                    "lib/crokus/cfg_cleaner.rb",
                    "lib/crokus/cfg_printer.rb",
                    "lib/crokus/cfg.rb",
                    "lib/crokus/cleaner.rb",
                    "lib/crokus/code.rb",
                    "lib/crokus/compiler.rb",
                    "lib/crokus/generic_lexer.rb",
                    "lib/crokus/indent.rb",
                    "lib/crokus/ir_dumper.rb",
                    "lib/crokus/lexer.rb",
                    "lib/crokus/parser_only.rb",
                    "lib/crokus/parser.rb",
                    "lib/crokus/pretty_printer.rb",
                    "lib/crokus/runner.rb",
                    "lib/crokus/tac_builder.rb",
                    "lib/crokus/token.rb",
                    "lib/crokus/transformer.rb",
                    "lib/crokus/version.rb",
                    "lib/crokus/visitor.rb",
                    "lib/crokus.rb"
                ]

  s.executables << 'crokus'
  s.homepage    = 'https://github.com/JC-LL/crokus'
  s.license     = 'MIT'
  s.post_install_message = "Thanks for installing ! Homepage :https://github.com/JC-LL/crokus"
  s.required_ruby_version = '>= 2.0.0'
end
