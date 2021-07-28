# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::EORTest < Vic20::Processor::Test
  def test_absolute_addressing_mode
    value = 0x0f
    mask = 0x3c
    address = 0x1b0e

    @memory.set_byte(address, value)
    @processor.a = mask

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_absolute_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c
    address = 0x1b0e

    @memory.set_byte(address, value)
    @processor.a = mask

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.eor

    assert_sign_flag
  end

  def test_absolute_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c
    address = 0x1b0e

    @memory.set_byte(address, value)
    @processor.a = mask

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.eor

    assert_zero_flag
  end

  def test_absolute_x_addressing_mode
    value = 0x0f
    mask = 0x3c
    address = 0x1bc1
    offset = 0x2e

    @memory.set_byte(address + offset, value)
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_absolute_x_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c
    address = 0x1bc1
    offset = 0x2e

    @memory.set_byte(address + offset, value)
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.eor

    assert_sign_flag
  end

  def test_absolute_x_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c
    address = 0x1bc1
    offset = 0x2e

    @memory.set_byte(address + offset, value)
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.eor

    assert_zero_flag
  end

  def test_absolute_y_addressing_mode
    value = 0x0f
    mask = 0x3c
    address = 0x1bc1
    offset = 0x2e

    @memory.set_byte(address + offset, value)
    @processor.y = offset
    @processor.a = mask

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_absolute_y_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c
    address = 0x1bc1
    offset = 0x2e

    @memory.set_byte(address + offset, value)
    @processor.y = offset
    @processor.a = mask

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.eor

    assert_sign_flag
  end

  def test_absolute_y_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c
    address = 0x1bc1
    offset = 0x2e

    @memory.set_byte(address + offset, value)
    @processor.y = offset
    @processor.a = mask

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.eor

    assert_zero_flag
  end

  def test_immediate_addressing_mode
    value = 0x0f
    mask = 0x3c

    @processor.a = mask

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_immediate_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c

    @processor.a = mask

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.eor

    assert_sign_flag
  end

  def test_immediate_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c

    @processor.a = mask

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.eor

    assert_zero_flag
  end

  def test_indirect_x_addressing_mode
    value = 0x0f
    mask = 0x3c
    indirect_address = 0x1bc1
    address = 0x9e
    offset = 0x2e

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_indirect_x_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c
    indirect_address = 0x1bc1
    address = 0x9e
    offset = 0x2e

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.eor

    assert_sign_flag
  end

  def test_indirect_x_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c
    indirect_address = 0x1bc1
    address = 0x9e
    offset = 0x2e

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.eor

    assert_zero_flag
  end

  def test_indirect_y_addressing_mode
    value = 0x0f
    mask = 0x3c
    indirect_address = 0x1bc1
    offset = 0x2e
    address = 0x9e

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset
    @processor.a = mask

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_indirect_y_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c
    indirect_address = 0x1bc1
    offset = 0x2e
    address = 0x9e

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset
    @processor.a = mask

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.eor

    assert_sign_flag
  end

  def test_indirect_y_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c
    indirect_address = 0x1bc1
    offset = 0x2e
    address = 0x9e

    @processor.y = offset
    @processor.a = mask

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.eor

    assert_zero_flag
  end

  def test_zero_page_addressing_mode
    value = 0x0f
    mask = 0x3c
    address = 0xc1

    @memory.set_byte(address, value)
    @processor.a = mask

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_zero_page_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c
    address = 0xc1

    @memory.set_byte(address, value)
    @processor.a = mask

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.eor

    assert_sign_flag
  end

  def test_zero_page_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c
    address = 0xc1

    @memory.set_byte(address, value)
    @processor.a = mask

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.eor

    assert_zero_flag
  end

  def test_zero_page_x_addressing_mode
    value = 0x0f
    mask = 0x3c
    address = 0xc1
    offset = 0x0e

    @memory.set_byte(lsb(address + offset), value)
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_zero_page_x_addressing_mode_when_negative
    value = 0x80
    mask = 0x3c
    address = 0xc1
    offset = 0x0e

    @memory.set_byte(lsb(address + offset), value)
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.eor

    assert_sign_flag
  end

  def test_zero_page_x_addressing_mode_when_zero
    value = 0x3c
    mask = 0x3c
    address = 0xc1
    offset = 0x0e

    @memory.set_byte(lsb(address + offset), value)
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.eor

    assert_zero_flag
  end

  def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
    value = 0x0f
    mask = 0x3c
    address = 0xc1
    offset = 0xff

    @memory.set_byte(lsb(address + offset), value)
    @processor.x = offset
    @processor.a = mask

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.eor

    assert_equal(value ^ mask, @processor.a)
  end
end
