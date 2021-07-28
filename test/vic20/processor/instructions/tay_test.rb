# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::TAYTest < Vic20::Processor::Test
  def test_transfer_accumulator_to_y_register
    value = 0x0f

    @processor.a = value
    @processor.y = 0xdd
    @processor.p = 0

    @processor.tay

    assert_equal(value, @processor.y)
    refute_sign_flag
    refute_zero_flag
  end

  def test_transfer_accumulator_to_y_register_when_zero
    value = 0

    @processor.a = value
    @processor.y = 0xdd
    @processor.p = 0

    @processor.tay

    refute_sign_flag
    assert_zero_flag
  end

  def test_transfer_accumulator_to_y_register_when_negative
    value = 0xf0

    @processor.a = value
    @processor.y = 0xdd
    @processor.p = 0

    @processor.tay

    assert_sign_flag
    refute_zero_flag
  end
end
