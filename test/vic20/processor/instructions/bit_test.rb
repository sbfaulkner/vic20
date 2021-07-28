# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class BITTest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          mask = 0b00000001
          value = 0b11111111
          address = 0x19a9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.bit

          assert_sign_flag
          assert_overflow_flag
          refute_zero_flag
        end

        def test_absolute_addressing_mode_clears_sign_flag_when_bit_7_clear
          mask = 0b00000001
          value = 0b01111111
          address = 0x19a9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.bit

          refute_sign_flag
        end

        def test_absolute_addressing_mode_clears_overflow_flag_when_bit_6_clear
          mask = 0b00000001
          value = 0b10111111
          address = 0x19a9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.bit

          refute_overflow_flag
        end

        def test_absolute_addressing_mode_sets_zero_flag_when_zero
          mask = 0b00000001
          value = 0b11111110
          address = 0x19a9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.bit

          assert_zero_flag
        end

        def test_zero_page_addressing_mode
          mask = 0b00000001
          value = 0b11111111
          address = 0xa9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.bit

          assert_sign_flag
          assert_overflow_flag
          refute_zero_flag
        end

        def test_zero_page_addressing_mode_clears_sign_flag_when_bit_7_clear
          mask = 0b00000001
          value = 0b01111111
          address = 0xa9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.bit

          refute_sign_flag
        end

        def test_zero_page_addressing_mode_clears_overflow_flag_when_bit_6_clear
          mask = 0b00000001
          value = 0b10111111
          address = 0xa9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.bit

          refute_overflow_flag
        end

        def test_zero_page_addressing_mode_sets_zero_flag_when_zero
          mask = 0b00000001
          value = 0b11111110
          address = 0xa9

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.bit

          assert_zero_flag
        end
      end
    end
  end
end
