# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::CPXTest < Vic20::Processor::Test
  def test_absolute_addressing_mode_greater
    address = 0x1008

    @memory.set_byte(address, 0)
    @processor.x = 0x80

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.cpx

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_absolute_addressing_mode_equal
    address = 0x1008

    @memory.set_byte(address, 0x80)
    @processor.x = 0x80

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.cpx

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_absolute_addressing_mode_less
    address = 0x1008

    @memory.set_byte(address, 0xff)
    @processor.x = 0x80

    @processor.addressing_mode = :absolute
    @processor.operand = address
    @processor.cpx

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_immediate_addressing_mode_greater
    @processor.x = 0x80

    @processor.addressing_mode = :immediate
    @processor.operand = 0
    @processor.cpx

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_immediate_addressing_mode_equal
    @processor.x = 0x80

    @processor.addressing_mode = :immediate
    @processor.operand = 0x80
    @processor.cpx

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_immediate_addressing_mode_less
    @processor.x = 0x80

    @processor.addressing_mode = :immediate
    @processor.operand = 0xff
    @processor.cpx

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_addressing_mode_greater
    address = 0x34

    @memory.set_byte(address, 0)
    @processor.x = 0x80

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.cpx

    assert_carry_flag
    assert_sign_flag
    refute_zero_flag
  end

  def test_zero_page_addressing_mode_equal
    address = 0x34

    @memory.set_byte(address, 0x80)
    @processor.x = 0x80

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.cpx

    assert_carry_flag
    refute_sign_flag
    assert_zero_flag
  end

  def test_zero_page_addressing_mode_less
    address = 0x34

    @memory.set_byte(address, 0xff)
    @processor.x = 0x80

    @processor.addressing_mode = :zero_page
    @processor.operand = address
    @processor.cpx

    refute_carry_flag
    assert_sign_flag
    refute_zero_flag
  end
end
