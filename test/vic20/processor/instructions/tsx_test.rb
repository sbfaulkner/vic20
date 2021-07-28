# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::TSXTest < Vic20::Processor::Test
  def test_transfer_stack_pointer_to_x_register
    value = 0x0f

    @processor.s = value
    @processor.x = 0xdd
    @processor.p = 0

    @processor.tsx

    assert_equal(value, @processor.x)
    refute_sign_flag
    refute_zero_flag
  end

  def test_transfer_stack_pointer_to_x_register_when_zero
    value = 0

    @processor.s = value
    @processor.x = 0xdd
    @processor.p = 0

    @processor.tsx

    refute_sign_flag
    assert_zero_flag
  end

  def test_transfer_stack_pointer_to_x_register_when_negative
    value = 0xf0

    @processor.s = value
    @processor.x = 0xdd
    @processor.p = 0

    @processor.tsx

    assert_sign_flag
    refute_zero_flag
  end
end
