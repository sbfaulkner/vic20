# frozen_string_literal: true
require 'test_helper'

module IPC
  class MemoryMappedArrayTest < Minitest::Test
    SIZE = 64 * 1024

    def setup
      super
      @memory = IPC::MemoryMappedArray.new(SIZE)
    end

    def test_initialized_to_zero
      assert(@memory[0, SIZE].all?(&:zero?))
    end

    def test_get_at_single_value
      assert_equal(0, @memory[0])
    end

    def test_get_at_array
      assert_equal([0, 0, 0, 0, 0, 0, 0, 0], @memory[SIZE - 8, 8])
    end

    def test_get_at_raises_when_index_out_of_bounds
      assert_raises(IndexError) { @memory[SIZE] }
    end

    def test_get_at_raises_when_length_exceeds_bounds
      assert_raises(IndexError) { @memory[SIZE - 7, 8] }
    end

    def test_set_at_single_value
      @memory[0] = 0xff
      assert_equal(0xff, @memory[0])
    end

    def test_set_at_array
      @memory[SIZE - 8, 8] = [1, 2, 3, 4, 5, 6, 7, 8]
      assert_equal([1, 2, 3, 4, 5, 6, 7, 8], @memory[SIZE - 8, 8])
    end

    def test_set_at_raises_when_index_out_of_bounds
      assert_raises(IndexError) { @memory[SIZE] = 0xff }
    end

    def test_set_at_raises_when_length_exceeds_bounds
      assert_raises(IndexError) { @memory[SIZE - 7, 8] = [1, 2, 3, 4, 5, 6, 7, 8] }
    end

    def test_set_at_raises_when_array_expected
      assert_raises(TypeError) { @memory[SIZE - 8, 8] = 0xff }
    end

    def test_set_at_raises_when_array_too_short
      assert_raises(ArgumentError) { @memory[SIZE - 8, 8] = [1, 2, 3, 4, 5, 6, 7] }
    end

    def test_set_at_raises_when_array_too_long
      assert_raises(ArgumentError) { @memory[SIZE - 8, 8] = [1, 2, 3, 4, 5, 6, 7, 8, 9] }
    end
  end
end
