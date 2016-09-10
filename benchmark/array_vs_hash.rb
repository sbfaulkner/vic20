#!/usr/bin/env ruby

require 'benchmark'

ITERATIONS = 1_000_000

ARRAY = Array.new(64*1024) { |i| i >> 8 }
HASH = Array.new(64*1024) { |i| [i, i >> 8] }.to_h

Benchmark.bm(7) do |x|
  x.report('array:') { ITERATIONS.times { |i| ARRAY[i % (64*1024)] } }
  x.report('hash:') { ITERATIONS.times { |i| HASH[i % (64*1024)] } }
end
