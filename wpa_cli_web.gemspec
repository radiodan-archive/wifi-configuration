# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "wpa_cli_web"
  spec.version       = "0.0.14"
  spec.authors       = ["Chris Lowis", "Andrew Nicolaou"]
  spec.email         = ["chris.lowis@gmail.com"]
  spec.description   = %q{Web interface for configuring wifi using wpa_cli}
  spec.summary       = %q{Web interface for configuring wifi using wpa_cli}
  spec.homepage      = ""
  spec.license       = "Apache"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.default_executable = 'wpa_cli_web'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "wpa_cli_ruby", ">= 0.0.2"
  spec.add_dependency "thin"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
end
