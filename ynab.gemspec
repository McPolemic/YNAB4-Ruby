# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ynab/version'

Gem::Specification.new do |spec|
  spec.name          = "ynab"
  spec.version       = Ynab::VERSION
  spec.authors       = ["Adam Lukens"]
  spec.email         = ["alukens@purduefed.com"]
  spec.description   = %q{A read-only interface to YNAB 4 data files}
  spec.summary       = %q{A read-only interface to YNAB 4 data files}
  spec.homepage      = "https://github.com/McPolemic/YNAB4-Ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
