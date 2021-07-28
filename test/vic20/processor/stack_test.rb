# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    class StackTest < Vic20::Processor::Test
      def test_pop
        top = 0xff
        byte = 0xbf

        @memory.set_byte(0x100 + top, byte)
        @processor.s = top - 1

        assert_equal(byte, @processor.pop)
        assert_equal(top, @processor.s)
      end

      def test_pop_at_top
        top = 0xff

        @processor.s = top

        @processor.pop

        assert_equal(0, @processor.s)
      end

      def test_pop_word
        top = 0xff
        word = 0xbeef

        @memory.set_bytes(0x100 + top - 1, 2, [lsb(word), msb(word)])
        @processor.s = top - 2

        assert_equal(word, @processor.pop_word)
        assert_equal(top, @processor.s)
      end

      def test_push
        top = 0xff
        byte = 0xbf

        @processor.s = top

        @processor.push(byte)

        assert_equal(byte, @memory.get_byte(0x100 + top))
        assert_equal(top - 1, @processor.s)
      end

      def test_push_at_bottom
        top = 0xff
        byte = 0xbf

        @processor.s = 0

        @processor.push(byte)

        assert_equal(top, @processor.s)
      end

      def test_push_word
        top = 0xff
        word = 0xbeef

        @processor.s = top

        @processor.push_word(word)

        assert_equal(word, @memory.get_word(0x100 + top - 1))
        assert(top - 2, @processor.s)
      end
    end
  end
end
