#!/usr/bin/env ruby

require 'bundler/setup'
require 'benchmark'

ITERATIONS = 1_000_000

ABC = %w(a b c).freeze
BC = %w(b c).freeze
D = %w(d).freeze

Benchmark.bm(11) do |x|
  x.report('all?:')      { ITERATIONS.times { BC.all? { |r| ABC.include?(r) } } }
  x.report('intersect:') { ITERATIONS.times { (BC & ABC) == BC } }
  x.report('subtract:')  { ITERATIONS.times { (BC - ABC).empty? } }
end
