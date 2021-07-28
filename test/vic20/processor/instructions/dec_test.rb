# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class DECTest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          address = 0x1c05
          value = 1

          @memory.set_byte(address, value)

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address))
          refute_sign_flag
          assert_zero_flag
        end

        def test_absolute_addressing_mode_positive_result
          address = 0x1c05
          value = 0x80

          @memory.set_byte(address, value)

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address))
          refute_sign_flag
          refute_zero_flag
        end

        def test_absolute_addressing_mode_negative_result
          address = 0x1c05
          value = 0

          @memory.set_byte(address, value)

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.dec

          assert_equal(lsb(value - 1), @memory.get_byte(address))
          assert_sign_flag
          refute_zero_flag
        end

        def test_absolute_x_addressing_mode
          address = 0x1cd5
          offset = 0xbb
          value = 1

          @memory.set_byte(address + offset, value)
          @processor.x = offset

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address + offset))
          refute_sign_flag
          assert_zero_flag
        end

        def test_absolute_x_addressing_mode_positive_result
          address = 0x1cd5
          offset = 0xbb
          value = 0x80

          @memory.set_byte(address + offset, value)
          @processor.x = offset

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address + offset))
          refute_sign_flag
          refute_zero_flag
        end

        def test_absolute_x_addressing_mode_negative_result
          address = 0x1cd5
          offset = 0xbb
          value = 0

          @memory.set_byte(address + offset, value)
          @processor.x = offset

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.dec

          assert_equal(lsb(value - 1), @memory.get_byte(address + offset))
          assert_sign_flag
          refute_zero_flag
        end

        def test_zero_page_addressing_mode
          address = 0xc1
          value = 1

          @memory.set_byte(address, value)

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address))
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_addressing_mode_positive_result
          address = 0xc1
          value = 0x80

          @memory.set_byte(address, value)

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address))
          refute_sign_flag
          refute_zero_flag
        end

        def test_zero_page_addressing_mode_negative_result
          address = 0xc1
          value = 0

          @memory.set_byte(address, value)

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.dec

          assert_equal(lsb(value - 1), @memory.get_byte(address))
          assert_sign_flag
          refute_zero_flag
        end

        def test_zero_page_x_addressing_mode
          address = 0xc1
          offset = 0x18
          value = 1

          @memory.set_byte(address + offset, value)
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address + offset))
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode_positive_result
          address = 0xc1
          offset = 0x18
          value = 0x80

          @memory.set_byte(address + offset, value)
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(address + offset))
          refute_sign_flag
          refute_zero_flag
        end

        def test_zero_page_x_addressing_mode_negative_result
          address = 0xc1
          offset = 0x18
          value = 0

          @memory.set_byte(address + offset, value)
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.dec

          assert_equal(lsb(value - 1), @memory.get_byte(address + offset))
          assert_sign_flag
          refute_zero_flag
        end

        def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
          address = 0xc1
          offset = 0xff
          value = 1

          @memory.set_byte(lsb(address + offset), value)
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.dec

          assert_equal(value - 1, @memory.get_byte(lsb(address + offset)))
          refute_sign_flag
          assert_zero_flag
        end
      end
    end
  end
end
