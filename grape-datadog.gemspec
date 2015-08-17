# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape/datadog/version'

Gem::Specification.new do |gem|
  gem.name          = "grape-datadog"
  gem.version       = Grape::Datadog::VERSION.dup
  gem.authors       = ["Artem Chernyshev"]
  gem.email         = ["artem.0xD2@gmail.com"]
  gem.description   = %q{Datadog metrics for grape}
  gem.summary       = %q{Datadog metrics for grape}
  gem.homepage      = "https://github.com/Unix4ever/grape-datadog"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency(%q<grape>)
  gem.add_runtime_dependency(%q<dogstatsd-ruby>)

  gem.add_development_dependency(%q<rake>)
  gem.add_development_dependency(%q<bundler>)
  gem.add_development_dependency(%q<rack-test>)
  gem.add_development_dependency(%q<rspec>, "~> 3.0")
end
