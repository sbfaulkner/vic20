#!/usr/bin/env ruby

require 'benchmark'

ITERATIONS = 1_000_000

AR = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].freeze

def get_bytes(i)
  o = AR[0] # rubocop:disable Lint/UselessAssignment
  case i
  when 1
    AR[1]
  when 2
    AR[1] + AR[2] << 8
  end
end

def get_array(i)
  _o, l, h = AR[i, i + 1]
  case i
  when 1
    l
  when 2
    l + h << 8
  end
end

Benchmark.bm(7) do |x|
  x.report('bytes:') { ITERATIONS.times { |i| get_bytes(i % 3) } }
  x.report('array:') { ITERATIONS.times { |i| get_array(i % 3) } }
end
