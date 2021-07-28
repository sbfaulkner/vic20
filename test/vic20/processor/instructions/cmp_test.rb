# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::CMPTest < Vic20::Processor::Test
  def test_absolute_addressing_mode_greater
    address = 0x1008

    @memory.set_byte(address, 0)
    @processor.a = 0x80

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_addressing_mode_equal
    address = 0x1008

    @memory.set_byte(address, 0x80)
    @processor.a = 0x80

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_absolute_addressing_mode_less
    address = 0x1008

    @memory.set_byte(address, 0xff)
    @processor.a = 0x80

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_x_addressing_mode_greater
    address = 0x1003
    offset = 5

    @memory.set_byte(address + offset, 0)
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_x_addressing_mode_equal
    address = 0x1003
    offset = 5

    @memory.set_byte(address + offset, 0x80)
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_absolute_x_addressing_mode_less
    address = 0x1003
    offset = 5

    @memory.set_byte(address + offset, 0xff)
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_y_addressing_mode_greater
    address = 0x1003
    offset = 5

    @memory.set_byte(address + offset, 0)
    @processor.y = offset
    @processor.a = 0x80

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_y_addressing_mode_equal
    address = 0x1003
    offset = 5

    @memory.set_byte(address + offset, 0x80)
    @processor.y = offset
    @processor.a = 0x80

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_absolute_y_addressing_mode_less
    address = 0x1003
    offset = 5

    @memory.set_byte(address + offset, 0xff)
    @processor.y = offset
    @processor.a = 0x80

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_immediate_addressing_mode_greater
    @processor.a = 0x80

    @processor.addressing_mode = :immediate
    @processor.operand = 0
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_immediate_addressing_mode_equal
    @processor.a = 0x80

    @processor.addressing_mode = :immediate
    @processor.operand = 0x80
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_immediate_addressing_mode_less
    @processor.a = 0x80

    @processor.addressing_mode = :immediate
    @processor.operand = 0xff
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_indirect_x_addressing_mode_greater
    indirect_address = 0x034a
    address = 0xc1
    offset = 2

    @memory.set_byte(indirect_address, 0)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_indirect_x_addressing_mode_equal
    indirect_address = 0x034a
    address = 0xc1
    offset = 2

    @memory.set_byte(indirect_address, 0x80)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_indirect_x_addressing_mode_wraps_when_page_bounds_exceeded
    indirect_address = 0x034a
    address = 0xc1
    offset = 0xff

    @memory.set_byte(indirect_address, 0x80)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_indirect_x_addressing_mode_less
    indirect_address = 0x034a
    address = 0xc1
    offset = 2

    @memory.set_byte(indirect_address, 0xff)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_indirect_y_addressing_mode_greater
    indirect_address = 0x034a
    offset = 2
    address = 0xc1

    @memory.set_byte(indirect_address + offset, 0)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset
    @processor.a = 0x80

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_indirect_y_addressing_mode_equal
    indirect_address = 0x034a
    offset = 2
    address = 0xc1

    @memory.set_byte(indirect_address + offset, 0x80)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset
    @processor.a = 0x80

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_indirect_y_addressing_mode_less
    indirect_address = 0x034a
    offset = 2
    address = 0xc1

    @memory.set_byte(indirect_address + offset, 0xff)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset
    @processor.a = 0x80

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_addressing_mode_greater
    address = 0x34

    @memory.set_byte(address, 0)
    @processor.a = 0x80

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_addressing_mode_equal
    address = 0x34

    @memory.set_byte(address, 0x80)
    @processor.a = 0x80

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_zero_page_addressing_mode_less
    address = 0x34

    @memory.set_byte(address, 0xff)
    @processor.a = 0x80

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_x_addressing_mode_greater
    address = 0x34
    offset = 5

    @memory.set_byte(lsb(address + offset), 0)
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_x_addressing_mode_equal
    address = 0x34
    offset = 5

    @memory.set_byte(lsb(address + offset), 0x80)
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.cmp

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_zero_page_x_addressing_mode_less
    address = 0x34
    offset = 5

    @memory.set_byte(lsb(address + offset), 0xff)
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
    address = 0x34
    offset = 0xff

    @memory.set_byte(lsb(address + offset), 0xff)
    @processor.x = offset
    @processor.a = 0x80

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.cmp

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end
end
