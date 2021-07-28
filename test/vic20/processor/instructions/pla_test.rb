# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::PLATest < Vic20::Processor::Test
  def test_pull_accumulator
    value = 0x0d

    @processor.push(value)
    @processor.a = 0x0a

    @processor.pla

    assert_equal(value, @processor.a)
    refute_sign_flag
    refute_zero_flag
  end

  def test_pull_accumulator_when_zero
    value = 0

    @processor.push(value)
    @processor.a = 0x0a

    @processor.pla

    assert_equal(value, @processor.a)
    refute_sign_flag
    assert_zero_flag
  end

  def test_pull_accumulator_when_negative
    value = 0xd0

    @processor.push(value)
    @processor.a = 0x0a

    @processor.pla

    assert_equal(value, @processor.a)
    assert_sign_flag
    refute_zero_flag
  end
end
