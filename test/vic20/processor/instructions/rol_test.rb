# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class ROLTest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          address = 0x1bee
          value = 0b11101010

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1), @memory.get_byte(address))
          assert_carry_flag
          assert_sign_flag
          refute_zero_flag
        end

        def test_absolute_addressing_mode_when_carry_flag_set
          address = 0x1bee
          value = 0b11101010

          @memory.set_byte(address, value)
          @processor.p = Vic20::Processor::C_FLAG

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1) | 0x01, @memory.get_byte(address))
        end

        def test_absolute_addressing_mode_when_zero
          address = 0x1bee
          value = 0

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.rol

          assert_equal(value, @memory.get_byte(address))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_absolute_x_addressing_mode
          address = 0x1bee
          value = 0b11101010
          offset = 0xcc

          @memory.set_byte(address + offset, value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1), @memory.get_byte(address + offset))
          assert_carry_flag
          assert_sign_flag
          refute_zero_flag
        end

        def test_absolute_x_addressing_mode_when_carry_flag_set
          address = 0x1bee
          value = 0b11101010
          offset = 0xcc

          @memory.set_byte(address + offset, value)
          @processor.x = offset
          @processor.p = Vic20::Processor::C_FLAG

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1) | 0x01, @memory.get_byte(address + offset))
        end

        def test_absolute_x_addressing_mode_when_zero
          address = 0x1bee
          value = 0
          offset = 0xcc

          @memory.set_byte(address + offset, value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.rol

          assert_equal(value, @memory.get_byte(address + offset))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_accumulator_addressing_mode
          value = 0b11101010

          @processor.a = value
          @processor.p = 0

          @processor.addressing_mode = :accumulator
          @processor.rol

          assert_equal(lsb(value << 1), @processor.a)
          assert_carry_flag
          assert_sign_flag
          refute_zero_flag
        end

        def test_accumulator_addressing_mode_when_carry_flag_set
          value = 0b11101010

          @processor.a = value
          @processor.p = Vic20::Processor::C_FLAG

          @processor.addressing_mode = :accumulator
          @processor.rol

          assert_equal(lsb(value << 1) | 0x01, @processor.a)
        end

        def test_accumulator_addressing_mode_when_zero
          value = 0

          @processor.a = value
          @processor.p = 0

          @processor.addressing_mode = :accumulator
          @processor.rol

          assert_equal(value, @processor.a)
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_addressing_mode
          address = 0x4e
          value = 0b11101010

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1), @memory.get_byte(address))
          assert_carry_flag
          assert_sign_flag
          refute_zero_flag
        end

        def test_zero_page_addressing_mode_when_carry_flag_set
          address = 0x4e
          value = 0b11101010

          @memory.set_byte(address, value)
          @processor.p = Vic20::Processor::C_FLAG

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1) | 0x01, @memory.get_byte(address))
        end

        def test_zero_page_addressing_mode_when_zero
          address = 0x4e
          value = 0

          @memory.set_byte(address, value)
          @processor.p = 0

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.rol

          assert_equal(value, @memory.get_byte(address))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode
          address = 0x4e
          value = 0b11101010
          offset = 1

          @memory.set_byte((address + offset) & 0xff, value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1), @memory.get_byte(lsb(address + offset)))
          assert_carry_flag
          assert_sign_flag
          refute_zero_flag
        end

        def test_zero_page_x_addressing_mode_when_carry_flag_set
          address = 0x4e
          value = 0b11101010
          offset = 1

          @memory.set_byte((address + offset) & 0xff, value)
          @processor.x = offset
          @processor.p = Vic20::Processor::C_FLAG

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1) | 0x01, @memory.get_byte(lsb(address + offset)))
        end

        def test_zero_page_x_addressing_mode_when_zero
          address = 0x4e
          value = 0
          offset = 1

          @memory.set_byte((address + offset) & 0xff, value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.rol

          assert_equal(value, @memory.get_byte(lsb(address + offset)))
          refute_carry_flag
          refute_sign_flag
          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
          address = 0x4e
          value = 0b11101010
          offset = 0xff

          @memory.set_byte((address + offset) & 0xff, value)
          @processor.x = offset
          @processor.p = 0

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.rol

          assert_equal(lsb(value << 1), @memory.get_byte(lsb(address + offset)))
        end
      end
    end
  end
end
