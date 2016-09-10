#!/usr/bin/env ruby

require 'benchmark'

ITERATIONS = 1_000_000

def useif(i)
  if i.even?
    @p = i / 2
  else
    @p = i * 2
  end
end

def useifret(i)
  @p = if i.even?
    i / 2
  else
    i * 2
  end
end

def userternary(i)
  @p = i.even? ? (i / 2) : (i * 2)
end

Benchmark.bm(9) do |x|
  x.report('if:') { ITERATIONS.times { |i| useif(i) } }
  x.report('ifret:') { ITERATIONS.times { |i| useifret(i) } }
  x.report('ternary:') { ITERATIONS.times { |i| userternary(i) } }
end
