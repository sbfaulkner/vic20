# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::DEYTest < Vic20::Processor::Test
  def test_decrement_y_register
    y = 1

    @processor.y = y

    @processor.dey

    assert_equal(y - 1, @processor.y)
    refute_sign_flag
    assert_zero_flag
  end

  def test_decrement_y_register_positive_result
    y = 0x80

    @processor.y = y

    @processor.dey

    assert_equal(y - 1, @processor.y)
    refute_sign_flag
    refute_zero_flag
  end

  def test_decrement_y_register_negative_result
    y = 0

    @processor.y = y

    @processor.dey

    assert_equal(lsb(y - 1), @processor.y)
    assert_sign_flag
    refute_zero_flag
  end
end
