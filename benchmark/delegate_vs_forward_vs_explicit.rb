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

simple_delegator = SimpleDelegatorAccess.new
forwardable      = ForwardableAccess.new
explicit         = ExplicitAccess.new

Benchmark.bm(17) do |x|
  x.report('SimpleDelegator:') { ITERATIONS.times { |i| simple_delegator[i] } }
  x.report('Forwardable:')     { ITERATIONS.times { |i| forwardable[i] } }
  x.report('Explicit:')        { ITERATIONS.times { |i| explicit[i] } }
end
