# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class STYTest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          address = 0x284
          value = 0x03

          @memory.set_byte(address, 0xff)
          @processor.y = value

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.sty

          assert_equal(value, @memory.get_byte(address))
        end

        def test_zero_page_addressing_mode
          address = 0xb3
          value = 0x03

          @memory.set_byte(address, 0xff)
          @processor.y = value

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.sty

          assert_equal(value, @memory.get_byte(address))
        end

        def test_zero_page_x_addressing_mode
          address = 0x00
          offset = 0x0f
          value = 0x03

          @memory.set_byte(address + offset, 0xff)
          @processor.x = offset
          @processor.y = value

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.sty

          assert_equal(value, @memory.get_byte(address + offset))
        end

        def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
          address = 0xff
          offset = 0x0f
          value = 0x03

          @memory.set_byte(lsb(address + offset), 0xff)
          @processor.x = offset
          @processor.y = value

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.sty

          assert_equal(value, @memory.get_byte(lsb(address + offset)))
        end
      end
    end
  end
end
