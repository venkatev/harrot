# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "harrot"
  spec.version       = '1.0'
  spec.authors       = ["Vikram Venkatesan"]
  spec.email         = ["s.venkat.vikram@gmail.com"]
  spec.summary       = %q{HTTP Stubbing library}
  spec.description   = %q{HTTP Stubbing library}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'async-rack'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
