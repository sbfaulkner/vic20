# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vic20/version'

Gem::Specification.new do |spec|
  spec.name          = 'vic20'
  spec.version       = Vic20::VERSION
  spec.authors       = ['S. Brent Faulkner']
  spec.email         = ['brent.faulkner@shopify.com']

  spec.summary       = 'Ruby VIC-20 emulator.'
  spec.homepage      = 'http://github.com/sbfaulkner/vic20'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'gosu', '~> 0.10'
  spec.add_dependency 'texplay', '0.4.4.pre'
  spec.add_dependency 'pry', '~> 0.10'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'guard', '~> 2.13'
  spec.add_development_dependency 'guard-rspec', '~> 4.6'
  spec.add_development_dependency 'pry-byebug', '~> 3.4'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.42'
  spec.add_development_dependency 'stackprof', '~> 0.2'
end
