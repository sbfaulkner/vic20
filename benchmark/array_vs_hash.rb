#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'

ITERATIONS = 1_000_000

SIZE = 64 * 1024

ARRAY = Array.new(SIZE) { |i| i >> 8 }
HASH = Hash[Array.new(SIZE) { |i| [i, i >> 8] }]

Benchmark.bm(7) do |x|
  x.report('array:') { ITERATIONS.times { |i| ARRAY[i % SIZE] } }
  x.report('hash:')  { ITERATIONS.times { |i| HASH[i % SIZE] } }
end
