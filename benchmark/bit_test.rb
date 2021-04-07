#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'

ITERATIONS = 1_000_000

value = 0xa7

Benchmark.bm(7) do |x|
  x.report('array:') { ITERATIONS.times { value[2] == 0 } }
  x.report('zero?:') { ITERATIONS.times { value[2].zero? } }
  x.report('mask0:') { ITERATIONS.times { (value & 0x04) == 0 } }
  x.report('mask1:') { ITERATIONS.times { (value & 0x04) != 0x04 } }
  x.report('set:')   { ITERATIONS.times { (value & 0x04) == 0x04 } }
  x.report('!zero:') { ITERATIONS.times { (value & 0x04) != 0 } }
end
