# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rlex/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rasmus Borgsmidt"]
  gem.email         = ["rasmus@borgsmidt.dk"]
  gem.description   = %q{Implements a simple lexer using a StringScanner}
  gem.summary       = %q{The lexer was written for use with Racc, a
                         Ruby variant of Yacc. But there is no code
                         dependency on that project so the lexer may
                         also be used on its own or with other packages.}
  gem.homepage      = "https://github.com/borgsmidt/rlex"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rlex"
  gem.require_paths = ["lib"]
  gem.version       = Rlex::VERSION
end
