# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class STXTest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          value = 0x3c
          address = 0x0283

          @memory.set_byte(address, 0xff)
          @processor.x = value

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.stx

          assert_equal(value, @memory.get_byte(address))
        end

        def test_zero_page_addressing_mode
          value = 0x3c
          address = 0xb2

          @memory.set_byte(address, 0xff)
          @processor.x = value

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.stx

          assert_equal(value, @memory.get_byte(address))
        end

        def test_zero_page_y_addressing_mode
          value = 0x3c
          address = 0xb2
          offset = 5

          @memory.set_byte(address + offset, 0xff)
          @processor.x = value
          @processor.y = offset

          @processor.addressing_mode = :zero_page_y
          @processor.operand = address
          @processor.stx

          assert_equal(value, @memory.get_byte(address + offset))
        end

        def test_zero_page_y_addressing_mode_wraps_when_page_bounds_exceeded
          value = 0x3c
          address = 0xb2
          offset = 0xff

          @memory.set_byte(lsb(address + offset), 0xff)
          @processor.x = value
          @processor.y = offset

          @processor.addressing_mode = :zero_page_y
          @processor.operand = address
          @processor.stx

          assert_equal(value, @memory.get_byte(lsb(address + offset)))
        end
      end
    end
  end
end
