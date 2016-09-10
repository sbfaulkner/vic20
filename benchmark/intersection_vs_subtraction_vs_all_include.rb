#!/usr/bin/env ruby

require 'benchmark'

ITERATIONS = 1_000_000

ABC = %w(a b c)
BC = %w(b c)
D = %w(d)

Benchmark.bm(11) do |x|
  x.report('all?:') { ITERATIONS.times { |i| BC.all? { |r| ABC.include?(r) } } }
  x.report('intersect:') { ITERATIONS.times { |i| (BC & ABC) == BC } }
  x.report('subtract:') { ITERATIONS.times { |i| (BC - ABC).empty? } }
end
