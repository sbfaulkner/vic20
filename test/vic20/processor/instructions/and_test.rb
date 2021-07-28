# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::ANDTest < Vic20::Processor::Test
  def test_absolute_addressing_mode
    address = 0x1ead
    value = 0x0f
    mask = 0xfc

    @memory.set_byte(address, value)
    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_absolute_addressing_mode_sets_sign_flag
    address = 0x1ead
    value = 0x80
    mask = 0xfc

    @memory.set_byte(address, value)
    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.and

    assert_sign_flag
  end

  def test_absolute_addressing_mode_sets_zero_flag
    address = 0x1ead
    value = 0x01
    mask = 0xfc

    @memory.set_byte(address, value)
    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.and

    assert_zero_flag
  end

  def test_absolute_x_addressing_mode
    address = 0x1bad
    offset = 0xff
    value = 0x0f
    mask = 0xfc

    @memory.set_byte(address + offset, value)
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_absolute_x_addressing_mode_sets_sign_flag
    address = 0x1bad
    offset = 0xff
    value = 0x80
    mask = 0xfc

    @memory.set_byte(address + offset, value)
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.and

    assert_sign_flag
  end

  def test_absolute_x_addressing_mode_sets_zero_flag
    address = 0x1bad
    offset = 0xff
    value = 0x01
    mask = 0xfc

    @memory.set_byte(address + offset, value)
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.and

    assert_zero_flag
  end

  def test_absolute_y_addressing_mode
    address = 0x1bad
    offset = 0xff
    value = 0x0f
    mask = 0xfc

    @memory.set_byte(address + offset, value)
    @processor.p = 0
    @processor.a = mask
    @processor.y = offset

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_absolute_y_addressing_mode_sets_sign_flag
    address = 0x1bad
    offset = 0xff
    value = 0x80
    mask = 0xfc

    @memory.set_byte(address + offset, value)
    @processor.p = 0
    @processor.a = mask
    @processor.y = offset

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.and

    assert_sign_flag
  end

  def test_absolute_y_addressing_mode_sets_zero_flag
    address = 0x1bad
    offset = 0xff
    value = 0x01
    mask = 0xfc

    @memory.set_byte(address + offset, value)
    @processor.p = 0
    @processor.a = mask
    @processor.y = offset

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.and

    assert_zero_flag
  end

  def test_immediate_addressing_mode
    value = 0x0f
    mask = 0xfc

    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_immediate_addressing_mode_sets_sign_flag
    value = 0x80
    mask = 0xfc

    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.and

    assert_sign_flag
  end

  def test_immediate_addressing_mode_sets_zero_flag
    value = 0x01
    mask = 0xfc

    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :immediate
    @processor.operand = value
    @processor.and

    assert_zero_flag
  end

  def test_indirect_x_addressing_mode
    indirect_address = 0x1ead
    address = 0x4c
    offset = 2
    mask = 0xfc
    value = 0x0f

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_indirect_x_addressing_mode_sets_sign_flag
    indirect_address = 0x1ead
    address = 0x4c
    offset = 2
    mask = 0xfc
    value = 0x80

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.and

    assert_sign_flag
  end

  def test_indirect_x_addressing_mode_sets_zero_flag
    indirect_address = 0x1ead
    address = 0x4c
    offset = 2
    mask = 0xfc
    value = 0x01

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.and

    assert_zero_flag
  end

  def test_indirect_x_addressing_mode_wraps_around_when_offset_exceeds_page_bounds
    indirect_address = 0x1ead
    address = 0x4c
    offset = 0xff
    mask = 0xfc
    value = 0x0f

    @memory.set_byte(indirect_address, value)
    @memory.set_bytes(lsb(address + offset), 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)
  end

  def test_indirect_y_addressing_mode
    indirect_address = 0x1ead
    address = 0x4c
    offset = 2
    mask = 0xfc
    value = 0x0f

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.p = 0
    @processor.a = mask
    @processor.y = offset

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_indirect_y_addressing_mode_sets_sign_flag
    indirect_address = 0x1ead
    address = 0x4c
    offset = 2
    mask = 0xfc
    value = 0x80

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.p = 0
    @processor.a = mask
    @processor.y = offset

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.and

    assert_sign_flag
  end

  def test_indirect_y_addressing_mode_sets_zero_flag
    indirect_address = 0x1ead
    address = 0x4c
    offset = 2
    mask = 0xfc
    value = 0x01

    @memory.set_byte(indirect_address + offset, value)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.p = 0
    @processor.a = mask
    @processor.y = offset

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.and

    assert_zero_flag
  end

  def test_zero_page_addressing_mode
    address = 0xad
    mask = 0xfc
    value = 0x0f

    @memory.set_byte(address, value)
    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_zero_page_addressing_mode_sets_sign_flag
    address = 0xad
    mask = 0xfc
    value = 0x80

    @memory.set_byte(address, value)
    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.and

    assert_sign_flag
  end

  def test_zero_page_addressing_mode_sets_zero_flag
    address = 0xad
    mask = 0xfc
    value = 0x01

    @memory.set_byte(address, value)
    @processor.p = 0
    @processor.a = mask

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.and

    assert_zero_flag
  end

  def test_zero_page_x_addressing_mode
    address = 0xad
    offset = 5
    mask = 0xfc
    value = 0x0f

    @memory.set_byte(lsb(address + offset), value)
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end

  def test_zero_page_x_addressing_mode_sets_sign_flag
    address = 0xad
    offset = 5
    mask = 0xfc
    value = 0x80

    @memory.set_byte(lsb(address + offset), value)
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.and

    assert_sign_flag
  end

  def test_zero_page_x_addressing_mode_sets_zero_flag
    address = 0xad
    offset = 5
    mask = 0xfc
    value = 0x01

    @memory.set_byte(lsb(address + offset), value)
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.and

    assert_zero_flag
  end

  def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
    address = 0xad
    offset = 0xff
    mask = 0xfc
    value = 0x0f

    @memory.set_byte(lsb(address + offset), value)
    @processor.p = 0
    @processor.a = mask
    @processor.x = offset

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.and

    assert_equal(value & mask, @processor.a)

    refute_sign_flag
    refute_zero_flag
  end
end
