# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::STATest < Vic20::Processor::Test
  def test_absolute_addressing_mode
    address = 0x0281
    value = 0

    @memory.set_byte(address, 0xff)
    @processor.a = value

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(address))
  end

  def test_absolute_x_addressing_mode
    offset = 0x0f
    address = 0x0200
    value = 0

    @memory.set_byte(address + offset, 0xff)
    @processor.x = offset
    @processor.a = value

    @processor.addressing_mode = :absolute_x
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(address + offset))
  end

  def test_absolute_y_addressing_mode
    offset = 0x0f
    address = 0x0200
    value = 0

    @memory.set_byte(address + offset, 0xff)
    @processor.y = offset
    @processor.a = value

    @processor.addressing_mode = :absolute_y
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(address + offset))
  end

  def test_indirect_x_addressing_mode
    indirect_address = 0x034a
    address = 0xc1
    offset = 2
    value = 0x55

    @memory.set_byte(indirect_address, 0xff)
    @memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = value

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(indirect_address))
  end

  def test_indirect_x_addressing_mode_wraps_when_page_bounds_exceeded
    indirect_address = 0x034a
    address = 0xc1
    offset = 0xff
    value = 0x55

    @memory.set_byte(indirect_address, 0xff)
    @memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.x = offset
    @processor.a = value

    @processor.addressing_mode = :indirect_x
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(indirect_address))
  end

  def test_indirect_y_addressing_mode
    indirect_address = 0x034a
    address = 0xc1
    offset = 2
    value = 0x55

    @memory.set_byte(indirect_address + offset, 0xff)
    @memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
    @processor.y = offset
    @processor.a = value

    @processor.addressing_mode = :indirect_y
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(indirect_address + offset))
  end

  def test_zero_page_addressing_mode
    offset = 0xc1
    value = 0

    @memory.set_byte(offset, 0xff)
    @processor.a = value

    @processor.addressing_mode = :zero_page
    @processor.operand = offset
    @processor.sta

    assert_equal(value, @memory.get_byte(offset))
  end

  def test_zero_page_x_addressing_mode
    address = 0x09
    offset = 0x0f
    value = 0

    @memory.set_byte(offset, 0xff)
    @processor.x = offset
    @processor.a = value

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(address + offset))
  end

  def test_zero_page_x_addressing_mode_wraps_when_page_bounds_exceeded
    address = 0xff
    offset = 0x0f
    value = 0

    @memory.set_byte(offset, 0xff)
    @processor.x = offset
    @processor.a = value

    @processor.addressing_mode = :zero_page_x
    @processor.operand = address
    @processor.sta

    assert_equal(value, @memory.get_byte(lsb(address + offset)))
  end
end
