# coding: utf-8
# frozen_string_literal: true
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

  spec.add_dependency 'gosu'#, '~> 0.10'
  spec.add_dependency 'texplay', '0.4.4.pre'
  spec.add_dependency 'pry', '~> 0.14'
  spec.add_dependency 'ffi'
  spec.add_dependency 'scanf'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'stackprof', '~> 0.2.16'
  spec.add_development_dependency 'ruby-debug-ide'
  spec.add_development_dependency 'debase'
  spec.add_development_dependency 'rubocop-shopify'
end
