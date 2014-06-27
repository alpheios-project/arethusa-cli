# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arethusa_plugin_generator/version'

Gem::Specification.new do |spec|
  spec.name          = "arethusa_plugin_generator"
  spec.version       = ArethusaPluginGenerator::VERSION
  spec.authors       = ["LFDM"]
  spec.email         = ["1986gh@gmail.com"]
  spec.summary       = %q{Generates a skeleton for an Arethusa plugin}
  spec.description   = %q{TODO: Write a longer description. Optional.}
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
end
