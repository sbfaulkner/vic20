#!/usr/bin/env ruby

require 'benchmark'

ITERATIONS = 1_000_000

require 'delegate'
require 'forwardable'

class SimpleDelegatorAccess < SimpleDelegator
  def initialize
    super Array(ITERATIONS) { |i| i }
  end
end

class ForwardableAccess
  extend Forwardable

  def_delegators :@array, :[]

  def initialize
    @array = Array(ITERATIONS) { |i| i }
  end
end

class ExplicitAccess
  def initialize
    @array = Array(ITERATIONS) { |i| i }
  end

  def [](*args)
    @array.[](*args)
  end
end

Benchmark.bm(17) do |x|
  x.report('SimpleDelegator:') { a = SimpleDelegatorAccess.new; ITERATIONS.times { |i| a[i] } }
  x.report('Forwardable:') { a = ForwardableAccess.new; ITERATIONS.times { |i| a[i] } }
  x.report('Explicit:') { a = ExplicitAccess.new; ITERATIONS.times { |i| a[i] } }
end
