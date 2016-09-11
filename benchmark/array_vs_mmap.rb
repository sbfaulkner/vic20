#!/usr/bin/env ruby

require 'bundler/setup'
require 'benchmark'
require_relative '../lib/ipc/memory_mapped_array'

ITERATIONS = 1_000_000

SIZE = 64 * 1024

ARRAY = Array.new(SIZE) { |i| i >> 8 }
MMAP = IPC::MemoryMappedArray.new(SIZE) { |i| i >> 8 }

Benchmark.bm(8) do |x|
  x.report('array=:') { ITERATIONS.times { |i| ARRAY[i % (64 * 1024)] = i % 256 } }
  x.report('array:')  { ITERATIONS.times { |i| ARRAY[i % (64 * 1024)] } }
  x.report('mmap=:')  { ITERATIONS.times { |i| MMAP[i % (64 * 1024)] = i % 256 } }
  x.report('mmap:')   { ITERATIONS.times { |i| MMAP[i % (64 * 1024)] } }
end
