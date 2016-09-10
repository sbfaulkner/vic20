#!/usr/bin/env ruby

require 'benchmark'

ITERATIONS = 1_000_000

AR = [1,2,3,4,5,6,7,8,9,10]

def using_variable
  the_thing = AR[0]
  yield the_thing
end

def the_thing
  AR[0]
end

def using_method
  yield the_thing
end

Benchmark.bm(10) do |x|
  x.report('variable:') { ITERATIONS.times { |i| using_variable { |v| v } } }
  x.report('method:') { ITERATIONS.times { |i| using_method { |v| v } } }
end
