# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape/datadog/version'

Gem::Specification.new do |s|
  s.name          = "grape-datadog"
  s.version       = Grape::Datadog::VERSION.dup
  s.authors       = ["Artem Chernyshev", "Dimitrij Denissenko"]
  s.email         = ["artem.0xD2@gmail.com"]
  s.description   = %q{Datadog metrics for grape}
  s.summary       = %q{Datadog metrics for grape}
  s.homepage      = "https://github.com/bsm/grape-datadog"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(spec)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<grape>)
  s.add_runtime_dependency(%q<dogstatsd-ruby>)

  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<bundler>)
  s.add_development_dependency(%q<rack-test>)
  s.add_development_dependency(%q<rspec>, "~> 3.0")
end
