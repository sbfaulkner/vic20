# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class LSRTest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          address = 0x1e44
          value = 0b01110101

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.lsr

          assert_equal(lsb(value >> 1), @memory.get_byte(address))
          assert_carry_flag
          refute_sign_flag
          refute_zero_flag
        end

        def test_absolute_addressing_mode_when_zero
          address = 0x1e44
          value = 0

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.lsr

          assert_equal(value, @memory.get_byte(address))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_absolute_x_addressing_mode
          address = 0x1e44
          offset = 0xcc
          value = 0b01110101

          @memory.set_byte(address + offset, value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.lsr

          assert_equal(lsb(value >> 1), @memory.get_byte(address + offset))
          assert_carry_flag
          refute_sign_flag
          refute_zero_flag
        end

        def test_absolute_x_addressing_mode_when_zero
          address = 0x1e44
          offset = 0xcc
          value = 0

          @memory.set_byte(address + offset, value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.lsr

          assert_equal(value, @memory.get_byte(address + offset))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_accumulator_addressing_mode
          value = 0b01110101

          @processor.a = value
          @processor.p = 0

          @processor.addressing_mode = :accumulator
          @processor.lsr

          assert_equal(lsb(value >> 1), @processor.a)
          assert_carry_flag
          refute_sign_flag
          refute_zero_flag
        end

        def test_accumulator_addressing_mode_when_zero
          value = 0

          @processor.a = value
          @processor.p = 0

          @processor.addressing_mode = :accumulator
          @processor.lsr

          assert_equal(value, @processor.a)
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_addressing_mode
          address = 0xe4
          value = 0b01110101

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.lsr

          assert_equal(lsb(value >> 1), @memory.get_byte(address))
          assert_carry_flag
          refute_sign_flag
          refute_zero_flag
        end

        def test_zero_page_addressing_mode_when_zero
          address = 0xe4
          value = 0

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.lsr

          assert_equal(value, @memory.get_byte(address))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode
          address = 0xe4
          offset = 5
          value = 0b01110101

          @memory.set_byte(lsb(address + offset), value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.lsr

          assert_equal(lsb(value >> 1), @memory.get_byte(lsb(address + offset)))
          assert_carry_flag
          refute_sign_flag
          refute_zero_flag
        end

        def test_zero_page_x_addressing_mode_when_zero
          address = 0xe4
          offset = 5
          value = 0

          @memory.set_byte(lsb(address + offset), value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.lsr

          assert_equal(value, @memory.get_byte(lsb(address + offset)))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
          address = 0xe4
          offset = 0xff
          value = 0b01110101

          @memory.set_byte(lsb(address + offset), value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.lsr

          assert_equal(lsb(value >> 1), @memory.get_byte(lsb(address + offset)))
        end
      end
    end
  end
end
