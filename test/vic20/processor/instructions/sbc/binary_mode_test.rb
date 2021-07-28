# frozen_string_literal: true
require 'test_helper'

module Vic20::Processor::Instructions::SBC
  class BinaryModeTest < Vic20::Processor::Test
    def test_absolute_addressing_mode
      address = 0x1dd1
      a = 0x19
      value = 0x03

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_absolute_addressing_mode_when_borrow_occurs
      address = 0x1dd1
      a = 0x19
      value = 0xff

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.sbc

      refute_carry_flag
    end

    def test_absolute_addressing_mode_when_negative
      address = 0x1dd1
      a = 0x19
      value = 0x20

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.sbc

      assert_sign_flag
    end

    def test_absolute_addressing_mode_when_zero
      address = 0x1dd1
      a = 0x19
      value = 0x19

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.sbc

      assert_zero_flag
    end

    def test_absolute_x_addressing_mode
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0x03

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_absolute_x_addressing_mode_when_borrow_occurs
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0xff

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.sbc

      refute_carry_flag
    end

    def test_absolute_x_addressing_mode_when_negative
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0x20

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.sbc

      assert_sign_flag
    end

    def test_absolute_x_addressing_mode_when_zero
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0x19

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.sbc

      assert_zero_flag
    end

    def test_absolute_y_addressing_mode
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0x03

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_absolute_y_addressing_mode_when_borrow_occurs
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0xff

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.sbc

      refute_carry_flag
    end

    def test_absolute_y_addressing_mode_when_negative
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0x20

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.sbc

      assert_sign_flag
    end

    def test_absolute_y_addressing_mode_when_zero
      address = 0x1dd1
      offset = 0xd5
      a = 0x19
      value = 0x19

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.sbc

      assert_zero_flag
    end

    def test_immediate_addressing_mode
      a = 0x19
      value = 0x03

      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_immediate_addressing_mode_when_borrow_occurs
      a = 0x19
      value = 0xff

      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.sbc

      refute_carry_flag
    end

    def test_immediate_addressing_mode_when_negative
      a = 0x19
      value = 0x20

      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.sbc

      assert_sign_flag
    end

    def test_immediate_addressing_mode_when_zero
      a = 0x19
      value = 0x19

      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.sbc

      assert_zero_flag
    end

    [
      [[0x50, 0xf0], [0x60, false, false, false]],
      [[0x50, 0xb0], [0xa0, false, true, true]],
      [[0x50, 0x70], [0xe0, false, true, false]],
      [[0x50, 0x30], [0x20, true, false, false]],
      [[0xd0, 0xf0], [0xe0, false, true, false]],
      [[0xd0, 0xb0], [0x20, true, false, false]],
      [[0xd0, 0x70], [0x60, true, false, true]],
      [[0xd0, 0x30], [0xa0, true, true, false]],
    ].each do |(a, value), (r, c, n, v)|
      define_method("test_immediate_addressing_mode_subtracting_0x#{value.to_s(16)}_to_0x#{a.to_s(16)}") do
        @processor.a = a
        @processor.p = Vic20::Processor::C_FLAG # no borrow

        @processor.addressing_mode = :immediate
        @processor.operand = value
        @processor.sbc

        assert_equal(r, @processor.a)
        assert_equal(c, !!@processor.c?)
        assert_equal(n, !!@processor.n?)
        assert_equal(v, !!@processor.v?)
      end
    end

    def test_indirect_x_addressing_mode
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x03

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_indirect_x_addressing_mode_when_borrow_occurs
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0xff

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.sbc

      refute_carry_flag
    end

    def test_indirect_x_addressing_mode_when_negative
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x20

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.sbc

      assert_sign_flag
    end

    def test_indirect_x_addressing_mode_when_zero
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x19

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.sbc

      assert_zero_flag
    end

    def test_indirect_x_addressing_mode_wraps_when_page_bounds_exceeded
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 0xff
      a = 0x19
      value = 0x03

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
    end

    def test_indirect_y_addressing_mode
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x03

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_indirect_y_addressing_mode_when_borrow_occurs
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0xff

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.sbc

      refute_carry_flag
    end

    def test_indirect_y_addressing_mode_when_negative
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x20

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.sbc

      assert_sign_flag
    end

    def test_indirect_y_addressing_mode_when_zero
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x19

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.sbc

      assert_zero_flag
    end

    def test_indirect_y_addressing_mode_wraps_when_page_bounds_exceeded
      indirect_address = 0x1dd1
      address = 0xd1
      offset = 0xff
      a = 0x19
      value = 0x03

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
    end

    def test_zero_page_addressing_mode
      address = 0xd1
      a = 0x19
      value = 0x03

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_zero_page_addressing_mode_when_borrow_occurs
      address = 0xd1
      a = 0x19
      value = 0xff

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.sbc

      refute_carry_flag
    end

    def test_zero_page_addressing_mode_when_negative
      address = 0xd1
      a = 0x19
      value = 0x20

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.sbc

      assert_sign_flag
    end

    def test_zero_page_addressing_mode_when_zero
      address = 0xd1
      a = 0x19
      value = 0x19

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.sbc

      assert_zero_flag
    end

    def test_zero_page_x_addressing_mode
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x03

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
      assert_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_zero_page_x_addressing_mode_when_borrow_occurs
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0xff

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.sbc

      refute_carry_flag
    end

    def test_zero_page_x_addressing_mode_when_negative
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x20

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.sbc

      assert_sign_flag
    end

    def test_zero_page_x_addressing_mode_when_zero
      address = 0xd1
      offset = 5
      a = 0x19
      value = 0x19

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.sbc

      assert_zero_flag
    end

    def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
      address = 0xd1
      offset = 0xff
      a = 0x19
      value = 0x03

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = Vic20::Processor::C_FLAG # no borrow

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.sbc

      assert_equal(a - value, @processor.a)
    end
  end
end
