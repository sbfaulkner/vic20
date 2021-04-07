#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'

ITERATIONS = 1_000_000

def direct
  0x01
end

def indirect
  direct
end

def indirect2
  indirect
end

Benchmark.bm(11) do |x|
  x.report('direct:')    { ITERATIONS.times { direct } }
  x.report('indirect:')  { ITERATIONS.times { indirect } }
  x.report('indirect2:') { ITERATIONS.times { indirect2 } }
end
