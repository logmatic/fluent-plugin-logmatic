# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-logmatic"
  spec.version       = "0.9.1"
  spec.authors       = ["Logmatic support team"]
  spec.email         = ["support@logmatic.io"]
  spec.summary       = "Logmatic output plugin for Fluent event collector"
  spec.homepage      = "http://logmatic.io"
  spec.license       = "MIT"

  spec.files         = [".gitignore", "Gemfile", "LICENSE", "README.md", "Rakefile", "fluent-plugin-logmatic.gemspec", "lib/fluent/plugin/out_logmatic.rb", "lib/fluent/plugin/out_logmatic_http.rb"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yajl-ruby", "~> 1.2"
end
