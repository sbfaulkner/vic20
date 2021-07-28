# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vic20/version'

Gem::Specification.new do |spec|
  spec.name          = 'vic20'
  spec.version       = Vic20::VERSION
  spec.authors       = ['S. Brent Faulkner']
  spec.email         = ['brent.faulkner@shopify.com']

  spec.summary       = 'Ruby VIC-20 emulator.'
  spec.homepage      = 'http://github.com/sbfaulkner/vic20'

  spec.files         = %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency('gosu', '~> 1.2')
  spec.add_dependency('pry', '~> 0.14')
  spec.add_dependency('ffi')

  spec.add_development_dependency('debase')
  spec.add_development_dependency('minitest-focus')
  spec.add_development_dependency('minitest-reporters')
  spec.add_development_dependency('minitest')
  spec.add_development_dependency('mocha', '~> 1.13')
  spec.add_development_dependency('parser', '~> 3.0.1.0')
  spec.add_development_dependency('rake', '~> 13.0')
  spec.add_development_dependency('rubocop-minitest')
  spec.add_development_dependency('rubocop-performance')
  spec.add_development_dependency('rubocop-rake')
  spec.add_development_dependency('rubocop-shopify')
  spec.add_development_dependency('ruby-debug-ide')
  spec.add_development_dependency('stackprof', '~> 0.2.16')
end
