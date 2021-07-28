# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::INYTest < Vic20::Processor::Test
  def test_increment_y_register
    y = 0

    @processor.y = y

    @processor.iny

    assert_equal(y + 1, @processor.y)
    refute_sign_flag
    refute_zero_flag
  end

  def test_increment_y_register_negative_result
    y = 0x7f

    @processor.y = y

    @processor.iny

    assert_equal(y + 1, @processor.y)
    assert_sign_flag
    refute_zero_flag
  end

  def test_increment_y_register_zero_result
    y = 0xff

    @processor.y = y

    @processor.iny

    assert_equal(0, @processor.y)
    refute_sign_flag
    assert_zero_flag
  end
end
