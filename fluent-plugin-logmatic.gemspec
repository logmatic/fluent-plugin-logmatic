# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-logmatic"
  spec.version       = "0.0.1"
  spec.authors       = ["Logmatic support team"]
  spec.email         = ["support@logmatic.io"]
  spec.summary       = "Logmatic output plugin for Fluent event collector"
  spec.homepage      = "https://github.com/logmatic/fluent-plugin-logmatic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
