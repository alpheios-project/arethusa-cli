# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arethusa/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "arethusa-client"
  spec.version       = Arethusa::CLI::VERSION
  spec.authors       = ["LFDM","Bridget Almas","Frederik Baumgardt"]
  spec.email         = ["balmas@gmail.com"]
  spec.summary       = %q{Command line tools for Arethusa}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov", "~> 0.7"
  spec.add_dependency "thor"
  spec.add_dependency "nokogiri"
end
