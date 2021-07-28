# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::TYATest < Vic20::Processor::Test
  def test_transfer_y_register_to_accumulator
    value = 0x0f

    @processor.y = value
    @processor.a = 0xdd
    @processor.p = 0

    @processor.tya

    assert_equal(value, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_transfer_y_register_to_accumulator_when_zero
    value = 0

    @processor.y = value
    @processor.a = 0xdd
    @processor.p = 0

    @processor.tya

    refute_sign_flag
    assert_zero_flag
  end

  def test_transfer_y_register_to_accumulator_when_negative
    value = 0xf0

    @processor.y = value
    @processor.a = 0xdd
    @processor.p = 0

    @processor.tya

    assert_sign_flag
    refute_zero_flag
  end
end
