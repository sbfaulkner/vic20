# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::LDATest < Vic20::Processor::Test
  def test_absolute_addressing_mode
    address = 0x1d4d
    value = 0xd4

    @memory.set_byte(address, value)
    @processor.a = 0

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_addressing_mode_when_zero
    address = 0x1d4d
    value = 0

    @memory.set_byte(address, value)
    @processor.a = 0

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_absolute_x_addressing_mode
    address = 0x1d4d
    offset = 5
    value = 0xd4

    @memory.set_byte(address + offset, value)
    @processor.a = 0
    @processor.x = offset

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_x_addressing_mode_when_zero
    address = 0x1d4d
    offset = 5
    value = 0

    @memory.set_byte(address + offset, value)
    @processor.a = 0
    @processor.x = offset

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_absolute_y_addressing_mode
    address = 0x1d4d
    offset = 5
    value = 0xd4

    @memory.set_byte(address + offset, value)
    @processor.a = 0
    @processor.y = offset

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_y_addressing_mode_when_zero
    address = 0x1d4d
    offset = 5
    value = 0

    @memory.set_byte(address + offset, value)
    @processor.a = 0
    @processor.y = offset

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_immediate_addressing_mode
    value = 0xd4

    @processor.a = 0

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_immediate_addressing_mode_when_zero
    value = 0

    @processor.a = 0

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_indirect_x_addressing_mode
    value = 0xd4
    indirect_address = 0x034a
    address = 0xc1
    offset = 2

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_indirect_x_addressing_mode_when_zero
    value = 0
    indirect_address = 0x034a
    address = 0xc1
    offset = 2

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_indirect_x_addressing_mode_wraps_when_page_bounds_exceeded
    value = 0xd4
    indirect_address = 0x034a
    address = 0xc1
    offset = 0xff

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_indirect_y_addressing_mode
    value = 0xd4
    indirect_address = 0x034a
    offset = 2
    address = 0xc1

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_indirect_y_addressing_mode_when_zero
    value = 0
    indirect_address = 0x034a
    offset = 2
    address = 0xc1

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_zero_page_addressing_mode
    address = 0x09
    value = 0xd4

    @memory.set_byte(address, value)
    @processor.a = 0

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_addressing_mode_when_zero
    address = 0x09
    value = 0

    @memory.set_byte(address, value)
    @processor.a = 0

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_zero_page_x_addressing_mode
    value = 0xd4
    address = 0x09
    offset = 5

    @memory.set_byte(lsb(address + offset), value)
    @processor.a = 0
    @processor.x = offset

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_x_addressing_mode_when_zero
    value = 0
    address = 0x09
    offset = 5

    @memory.set_byte(lsb(address + offset), value)
    @processor.a = 0
    @processor.x = offset

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_zero_page_x_addressing_mode_when_page_bounds_exceeded
    value = 0xd4
    address = 0x09
    offset = 0xff

    @memory.set_byte(lsb(address + offset), value)
    @processor.a = 0
    @processor.x = offset

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.lda

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end
end
