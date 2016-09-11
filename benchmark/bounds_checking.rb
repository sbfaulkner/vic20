#!/usr/bin/env ruby

require 'bundler/setup'
require 'benchmark'
require_relative '../lib/memory_mapped_array'

ITERATIONS = 1_000_000

SIZE = 64 * 1024

class UncheckedArray < MemoryMappedArray
  def initialize(size)
    super
  end

  def [](index, length = nil)
    if length
      @bytes.get_array_of_uchar(index, length)
    else
      @bytes.get_uchar(index)
    end
  end

  def []=(index, length, value = nil)
    if value
      @bytes.put_array_of_uchar(index, value)
    else
      @bytes.put_uchar(index, length)
    end
  end
end

class CheckedArray < MemoryMappedArray
  def initialize(size)
    @size = size
    super
  end

  def [](index, length = nil)
    raise IndexError, "index #{index} outside of array bounds" if index >= @size
    if length
      raise IndexError, "index #{index} and length #{length} exceeds array bounds" if index + length - 1 >= @size
      @bytes.get_array_of_uchar(index, length)
    else
      @bytes.get_uchar(index)
    end
  end

  def []=(index, length, value = nil)
    raise IndexError, "index #{index} outside of array bounds" if index >= @size
    if value
      array = Array.try_convert(value)
      raise ArgumentError, 'assigned value is not an array' unless array
      raise ArgumentError, "array length #{array.size} incorrect" if array.size != length
      raise IndexError, "index #{index} and length #{length} exceeds array bounds" if index + length - 1 >= @size
      @bytes.put_array_of_uchar(index, value)
    else
      @bytes.put_uchar(index, length)
    end
  end
end

UNCHECKED = UncheckedArray.new(SIZE) { |i| i >> 8 }
CHECKED   = CheckedArray.new(SIZE)   { |i| i >> 8 }

Benchmark.bm(12) do |x|
  x.report('unchecked=:') { ITERATIONS.times { |i| UNCHECKED[i % (64 * 1024)] = i % 256 } }
  x.report('unchecked:')  { ITERATIONS.times { |i| UNCHECKED[i % (64 * 1024)] } }
  x.report('checked=:')   { ITERATIONS.times { |i| CHECKED[i % (64 * 1024)] = i % 256 } }
  x.report('checked:')    { ITERATIONS.times { |i| CHECKED[i % (64 * 1024)] } }
end
