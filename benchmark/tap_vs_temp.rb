#!/usr/bin/env ruby

require 'benchmark'

ITERATIONS = 1_000_000

def use_tap(i)
  i.tap do
    i + 1
  end
end

def use_temp(i)
  ii = i
  i += 1
  ii
end

Benchmark.bm(7) do |x|
  x.report('tap:') { ITERATIONS.times { |i| use_tap(i) } }
  x.report('temp:') { ITERATIONS.times { |i| use_temp(i) } }
end
