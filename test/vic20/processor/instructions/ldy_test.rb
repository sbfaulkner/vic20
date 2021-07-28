# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class LDYTest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          value = 0xea
          address = 0x1c5a

          @memory.set_byte(address, value)
          @processor.y = 0

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.ldy

          assert_equal(value, @processor.y)
          assert_sign_flag
          refute_zero_flag
        end

        def test_absolute_addressing_mode_when_zero
          value = 0
          address = 0x1c5a

          @memory.set_byte(address, value)
          @processor.y = 0

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.ldy

          refute_sign_flag
          assert_zero_flag
        end

        def test_absolute_x_addressing_mode
          value = 0xea
          address = 0x19a0
          offset = 5

          @memory.set_byte(address + offset, value)
          @processor.x = offset
          @processor.y = 0

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.ldy

          assert_equal(value, @processor.y)
          assert_sign_flag
          refute_zero_flag
        end

        def test_absolute_x_addressing_mode_when_zero
          value = 0
          address = 0x19a0
          offset = 5

          @memory.set_byte(address + offset, value)
          @processor.x = offset
          @processor.y = 0

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.ldy

          refute_sign_flag
          assert_zero_flag
        end

        def test_immediate_addressing_mode
          value = 0xea

          @processor.y = 0

          @processor.addressing_mode = :immediate
          @processor.operand = value
          @processor.ldy

          assert_equal(value, @processor.y)
          assert_sign_flag
          refute_zero_flag
        end

        def test_immediate_addressing_mode_when_zero
          value = 0

          @processor.y = 0

          @processor.addressing_mode = :immediate
          @processor.operand = value
          @processor.ldy

          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_addressing_mode
          value = 0xea
          address = 0xc1

          @memory.set_byte(address, value)
          @processor.y = 0

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.ldy

          assert_equal(value, @processor.y)
          assert_sign_flag
          refute_zero_flag
        end

        def test_zero_page_addressing_mode_when_zero
          value = 0
          address = 0xc1

          @memory.set_byte(address, value)
          @processor.y = 0

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.ldy

          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode
          value = 0xea
          address = 0x09
          offset = 5

          @memory.set_byte(lsb(address + offset), value)
          @processor.x = offset
          @processor.y = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.ldy

          assert_equal(value, @processor.y)
          assert_sign_flag
          refute_zero_flag
        end

        def test_zero_page_x_addressing_mode_when_zero
          value = 0
          address = 0x09
          offset = 5

          @memory.set_byte(lsb(address + offset), value)
          @processor.x = offset
          @processor.y = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.ldy

          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode_when_page_bounds_exceeded
          value = 0xea
          address = 0x09
          offset = 0xff

          @memory.set_byte(lsb(address + offset), value)
          @processor.x = offset
          @processor.y = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.ldy

          assert_equal(value, @processor.y)
        end
      end
    end
  end
end
