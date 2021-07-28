# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::INXTest < Vic20::Processor::Test
  def test_increment_x_register
    x = 0

    @processor.x = x

    @processor.inx

    assert_equal(x + 1, @processor.x)
    refute_sign_flag
    refute_zero_flag
  end

  def test_increment_x_register_negative_result
    x = 0x7f

    @processor.x = x

    @processor.inx

    assert_equal(x + 1, @processor.x)
    assert_sign_flag
    refute_zero_flag
  end

  def test_increment_x_register_zero_result
    x = 0xff

    @processor.x = x

    @processor.inx

    assert_equal(0, @processor.x)
    refute_sign_flag
    assert_zero_flag
  end
end
