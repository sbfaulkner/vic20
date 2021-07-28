# frozen_string_literal: true
require 'test_helper'

module Vic20::Processor::Instructions::ADC
  class BinaryModeTest < Vic20::Processor::Test
    def test_absolute_addressing_mode
      address = 0x123f
      a = 0x40
      value = 0x0f

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_absolute_addressing_mode_sets_carry_flag_when_result_greater_than_255
      address = 0x123f
      a = 0xfe
      value = 0x0f

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.adc

      assert_carry_flag
    end

    def test_absolute_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      address = 0x123f
      a = 0x7f
      value = 0x7f

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_absolute_addressing_mode_sets_zero_flag_when_result_is_zero
      address = 0x123f
      a = 0xf1
      value = 0x0f

      @memory.set_byte(address, value)

      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute
      @processor.operand = address
      @processor.adc

      assert_zero_flag
    end


    def test_absolute_x_addressing_mode
      address = 0x133f
      offset = 0xf5
      a = 0x40
      value = 0x0f

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_absolute_x_addressing_mode_sets_carry_flag_when_result_greater_than_255
      address = 0x133f
      offset = 0xf5
      a = 0xfe
      value = 0x0f

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.adc

      assert_carry_flag
    end

    def test_absolute_x_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      address = 0x133f
      offset = 0xf5
      a = 0x7f
      value = 0x7f

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_absolute_x_addressing_mode_sets_zero_flag_when_result_is_zero
      address = 0x133f
      offset = 0xf5
      a = 0xf1
      value = 0x0f

      @memory.set_byte(address + offset, value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_x
      @processor.operand = address
      @processor.adc

      assert_zero_flag
    end

    def test_absolute_y_addressing_mode
      address = 0x133f
      offset = 0xf5
      a = 0x40
      value = 0x0f

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_absolute_y_addressing_mode_sets_carry_flag_when_result_greater_than_255
      address = 0x133f
      offset = 0xf5
      a = 0xfe
      value = 0x0f

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.adc

      assert_carry_flag
    end

    def test_absolute_y_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      address = 0x133f
      offset = 0xf5
      a = 0x7f
      value = 0x7f

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_absolute_y_addressing_mode_sets_zero_flag_when_result_is_zero
      address = 0x133f
      offset = 0xf5
      a = 0xf1
      value = 0x0f

      @memory.set_byte(address + offset, value)
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :absolute_y
      @processor.operand = address
      @processor.adc

      assert_zero_flag
    end

    def test_immediate_addressing_mode
      a = 0x40
      value = 0x0f

      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_immediate_addressing_mode_sets_carry_flag_when_result_greater_than_255
      a = 0xfe
      value = 0x0f

      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.adc

      assert_carry_flag
    end

    def test_immediate_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      a = 0x7f
      value = 0x7f

      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_immediate_addressing_mode_sets_zero_flag_when_result_is_zero
      a = 0xf1
      value = 0x0f

      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.adc

      assert_zero_flag
    end

    [
      [[0x50, 0x10], [0x60, false, false, false]],
      [[0x50, 0x50], [0xa0, false, true, true]],
      [[0x50, 0x90], [0xe0, false, true, false]],
      [[0x50, 0xd0], [0x20, true, false, false]],
      [[0xd0, 0x10], [0xe0, false, true, false]],
      [[0xd0, 0x50], [0x20, true, false, false]],
      [[0xd0, 0x90], [0x60, true, false, true]],
      [[0xd0, 0xd0], [0xa0, true, true, false]],
    ].each do |(a, value), (r, c, n, v)|
      define_method("test_immediate_addressing_mode_adding_0x#{value.to_s(16)}_to_0x#{a.to_s(16)}") do
        @processor.a = a
        @processor.p = 0

        @processor.addressing_mode = :immediate
        @processor.operand = value
        @processor.adc

        assert_equal(r, @processor.a)

        assert_equal(c, !!@processor.c?)
        assert_equal(n, !!@processor.n?)
        assert_equal(v, !!@processor.v?)
      end
    end

    def test_indirect_x_addressing_mode
      indirect_address = 0x133f
      value = 0x0f
      address = 0x3f
      offset = 5
      a = 0x40

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_indirect_x_addressing_mode_sets_carry_flag_when_result_greater_than_255
      indirect_address = 0x133f
      value = 0x0f
      address = 0x3f
      offset = 5
      a = 0xfe

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.adc

      assert_carry_flag
    end

    def test_indirect_x_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      indirect_address = 0x133f
      value = 0x7f
      address = 0x3f
      offset = 5
      a = 0x7f

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_indirect_x_addressing_mode_sets_zero_flag_when_result_is_zero
      indirect_address = 0x133f
      value = 0x0f
      address = 0x3f
      offset = 5
      a = 0xf1

      @memory.set_byte(indirect_address, value)
      @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_x
      @processor.operand = address
      @processor.adc

      assert_zero_flag
    end

    def test_indirect_y_addressing_mode
      indirect_address = 0x133f
      value = 0x0f
      address = 0x3f
      offset = 5
      a = 0x40

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(lsb(address), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_indirect_y_addressing_mode_sets_carry_flag_when_result_greater_than_255
      indirect_address = 0x133f
      value = 0x0f
      address = 0x3f
      offset = 5
      a = 0xfe

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(lsb(address), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.adc

      assert_carry_flag
    end

    def test_indirect_y_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      indirect_address = 0x133f
      value = 0x7f
      address = 0x3f
      offset = 5
      a = 0x7f

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(lsb(address), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_indirect_y_addressing_mode_sets_zero_flag_when_result_is_zero
      indirect_address = 0x133f
      value = 0x0f
      address = 0x3f
      offset = 5
      a = 0xf1

      @memory.set_byte(indirect_address + offset, value)
      @memory.set_bytes(lsb(address), 2, [lsb(indirect_address), msb(indirect_address)])
      @processor.y = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :indirect_y
      @processor.operand = address
      @processor.adc

      assert_zero_flag
    end

    def test_zero_page_addressing_mode
      address = 0x3f
      value = 0x0f
      a = 0x40

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_zero_page_addressing_mode_sets_carry_flag_when_result_greater_than_255
      address = 0x3f
      value = 0x0f
      a = 0xfe

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.adc

      assert_carry_flag
    end

    def test_zero_page_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      address = 0x3f
      value = 0x7f
      a = 0x7f

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_zero_page_addressing_mode_sets_zero_flag_when_result_is_zero
      address = 0x3f
      value = 0x0f
      a = 0xf1

      @memory.set_byte(address, value)
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page
      @processor.operand = address
      @processor.adc

      assert_zero_flag
    end

    def test_zero_page_x_addressing_mode
      address = 0x3f
      offset = 5
      value = 0x0f
      a = 0x40

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)

      refute_carry_flag
      refute_sign_flag
      refute_zero_flag
    end

    def test_zero_page_x_addressing_mode_sets_carry_flag_when_result_greater_than_255
      address = 0x3f
      offset = 5
      value = 0x0f
      a = 0xfe

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.adc

      assert_carry_flag
    end

    def test_zero_page_x_addressing_mode_sets_overflow_flag_when_result_has_incorrect_sign
      address = 0x3f
      offset = 5
      value = 0x7f
      a = 0x7f

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.adc

      assert_overflow_flag
      assert_sign_flag
    end

    def test_zero_page_x_addressing_mode_sets_zero_flag_when_result_is_zero
      address = 0x3f
      offset = 5
      value = 0x0f
      a = 0xf1

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.adc

      assert_zero_flag
    end

    def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
      address = 0x3f
      offset = 0xff
      value = 0x0f
      a = 0x40

      @memory.set_byte(lsb(address + offset), value)
      @processor.x = offset
      @processor.a = a
      @processor.p = 0

      @processor.addressing_mode = :zero_page_x
      @processor.operand = address
      @processor.adc

      assert_equal(a + value, @processor.a)
    end
  end
end
