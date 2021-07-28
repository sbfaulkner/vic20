# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Memory
    class MappingTest < Minitest::Test
      ADDRESS = 0x1000

      def setup
        super

        @memory = Vic20::Memory.new
        @mapping = Vic20::Memory::Mapping.new(@memory, ADDRESS)
      end

      def test_returns_value_from_memory
        @memory.set_byte(ADDRESS + 7, 13)
        assert_equal(13, @mapping[7])
      end

      def test_sets_value_to_memory
        @mapping[7] = 13
        assert_equal(13, @memory.get_byte(ADDRESS + 7))
      end
    end
  end
end
