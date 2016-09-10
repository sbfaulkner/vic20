#!/usr/bin/env ruby

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
  x.report('direct:') { ITERATIONS.times { |i| direct } }
  x.report('indirect:') { ITERATIONS.times { |i| indirect } }
  x.report('indirect2:') { ITERATIONS.times { |i| indirect2 } }
end
