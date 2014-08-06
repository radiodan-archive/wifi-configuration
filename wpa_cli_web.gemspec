# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "wpa_cli_web"
  spec.version       = "0.0.15"
  spec.authors       = ["Chris Lowis", "Andrew Nicolaou", "Dan Nuttall"]
  spec.email         = ["andrew.nicolaou@bbc.co.uk"]
  spec.description   = %q{Web interface for configuring wifi using wpa_cli}
  spec.summary       = %q{Web interface for configuring wifi using wpa_cli}
  spec.homepage      = "http://radiodan.net"
  spec.license       = "Apache"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.default_executable = 'wpa_cli_web'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", "~> 1.4.5"
  spec.add_dependency "wpa_cli_ruby", ">= 0.0.2"
  spec.add_dependency "thin", "~> 1.5.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.3.2"
  spec.add_development_dependency "mocha", "~> 1.1.0"
end
