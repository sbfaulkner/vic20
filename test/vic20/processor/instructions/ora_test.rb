# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class ORATest < Vic20::Processor::Test
        def test_absolute_addressing_mode
          address = 0x0288
          mask = 0x1c
          value = 0x45

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_absolute_addressing_mode_when_negative
          address = 0x0288
          mask = 0x1c
          value = 0xc5

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.ora

          assert_sign_flag
        end

        def test_absolute_addressing_mode_when_zero
          address = 0x0288
          mask = 0
          value = 0

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :absolute
          @processor.operand = address
          @processor.ora

          assert_zero_flag
        end

        def test_absolute_x_addressing_mode
          address = 0x0288
          offset = 0xff
          mask = 0x1c
          value = 0x45

          @memory.set_byte(address + offset, value)
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_absolute_x_addressing_mode_when_negative
          address = 0x0288
          offset = 0xff
          mask = 0x1c
          value = 0xc5

          @memory.set_byte(address + offset, value)
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.ora

          assert_sign_flag
        end

        def test_absolute_x_addressing_mode_when_zero
          address = 0x0288
          offset = 0xff
          mask = 0
          value = 0

          @memory.set_byte(address + offset, value)
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :absolute_x
          @processor.operand = address
          @processor.ora

          assert_zero_flag
        end

        def test_absolute_y_addressing_mode
          address = 0x0288
          offset = 0xff
          mask = 0x1c
          value = 0x45

          @memory.set_byte(address + offset, value)
          @processor.a = mask
          @processor.y = offset

          @processor.addressing_mode = :absolute_y
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_absolute_y_addressing_mode_when_negative
          address = 0x0288
          offset = 0xff
          mask = 0x1c
          value = 0xc5

          @memory.set_byte(address + offset, value)
          @processor.a = mask
          @processor.y = offset

          @processor.addressing_mode = :absolute_y
          @processor.operand = address
          @processor.ora

          assert_sign_flag
        end

        def test_absolute_y_addressing_mode_when_zero
          address = 0x0288
          offset = 0xff
          mask = 0
          value = 0

          @memory.set_byte(address + offset, value)
          @processor.a = mask
          @processor.y = offset

          @processor.addressing_mode = :absolute_y
          @processor.operand = address
          @processor.ora

          assert_zero_flag
        end

        def test_immediate_addressing_mode
          mask = 0x1c
          value = 0x45

          @processor.a = mask

          @processor.addressing_mode = :immediate
          @processor.operand = value
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_immediate_addressing_mode_when_negative
          mask = 0x1c
          value = 0xc5

          @processor.a = mask

          @processor.addressing_mode = :immediate
          @processor.operand = value
          @processor.ora

          assert_sign_flag
        end

        def test_immediate_addressing_mode_when_zero
          mask = 0
          value = 0

          @processor.a = mask

          @processor.addressing_mode = :immediate
          @processor.operand = value
          @processor.ora

          assert_zero_flag
        end

        def test_indirect_x_addressing_mode
          indirect_address = 0x0288
          address = 0x28
          offset = 0xff
          mask = 0x1c
          value = 0x45

          @memory.set_byte(indirect_address, value)
          @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :indirect_x
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_indirect_x_addressing_mode_when_negative
          indirect_address = 0x0288
          address = 0x28
          offset = 0xff
          mask = 0x1c
          value = 0xc5

          @memory.set_byte(indirect_address, value)
          @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :indirect_x
          @processor.operand = address
          @processor.ora

          assert_sign_flag
        end

        def test_indirect_x_addressing_mode_when_zero
          indirect_address = 0x0288
          address = 0x28
          offset = 0xff
          mask = 0
          value = 0

          @memory.set_byte(indirect_address, value)
          @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :indirect_x
          @processor.operand = address
          @processor.ora

          assert_zero_flag
        end

        def test_indirect_y_addressing_mode
          indirect_address = 0x0288
          address = 0x28
          offset = 0xff
          mask = 0x1c
          value = 0x45

          @memory.set_byte(indirect_address + offset, value)
          @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
          @processor.a = mask
          @processor.y = offset

          @processor.addressing_mode = :indirect_y
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_indirect_y_addressing_mode_when_negative
          indirect_address = 0x0288
          address = 0x28
          offset = 0xff
          mask = 0x1c
          value = 0xc5

          @memory.set_byte(indirect_address + offset, value)
          @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
          @processor.a = mask
          @processor.y = offset

          @processor.addressing_mode = :indirect_y
          @processor.operand = address
          @processor.ora

          assert_sign_flag
        end

        def test_indirect_y_addressing_mode_when_zero
          indirect_address = 0x0288
          address = 0x28
          offset = 0xff
          mask = 0
          value = 0

          @memory.set_byte(indirect_address + offset, value)
          @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
          @processor.a = mask
          @processor.y = offset

          @processor.addressing_mode = :indirect_y
          @processor.operand = address
          @processor.ora

          assert_zero_flag
        end

        def test_zero_page_addressing_mode
          address = 0x88
          mask = 0x1c
          value = 0x45

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_zero_page_addressing_mode_when_negative
          address = 0x88
          mask = 0x1c
          value = 0xc5

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.ora

          assert_sign_flag
        end

        def test_zero_page_addressing_mode_when_zero
          address = 0x88
          mask = 0
          value = 0

          @memory.set_byte(address, value)
          @processor.a = mask

          @processor.addressing_mode = :zero_page
          @processor.operand = address
          @processor.ora

          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode
          address = 0x88
          offset = 0x08
          mask = 0x1c
          value = 0x45

          @memory.set_byte(lsb(address + offset), value)
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_zero_page_x_addressing_mode_when_negative
          address = 0x88
          offset = 0x08
          mask = 0x1c
          value = 0xc5

          @memory.set_byte(lsb(address + offset), value)
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.ora

          assert_sign_flag
        end

        def test_zero_page_x_addressing_mode_when_zero
          address = 0x88
          offset = 0x08
          mask = 0
          value = 0

          @memory.set_byte(lsb(address + offset), value)
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.ora

          assert_zero_flag
        end

        def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
          address = 0x88
          offset = 0xff
          mask = 0x1c
          value = 0x45

          @memory.set_byte(lsb(address + offset), value)
          @processor.a = mask
          @processor.x = offset

          @processor.addressing_mode = :zero_page_x
          @processor.operand = address
          @processor.ora

          assert_equal(value | mask, @processor.a)
        end
      end
    end
  end
end
