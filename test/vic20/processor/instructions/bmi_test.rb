# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::BMITest < Vic20::Processor::Test
  def test_branches_when_sign_flag_is_set
    pc = 0xfd49
    offset = 3

    @processor.pc = pc
    @processor.p = Vic20::Processor::N_FLAG

    @processor.addressing_mode = :relative
    @processor.operand = offset
    @processor.bmi

    assert_equal(pc + offset, @processor.pc)
  end

  def test_does_not_branch_when_sign_flag_is_clear
    pc = 0xfd49
    offset = 3

    @processor.pc = pc
    @processor.p = 0

    @processor.addressing_mode = :relative
    @processor.operand = offset
    @processor.bmi

    assert_equal(pc, @processor.pc)
  end

  def test_branches_backwards_with_a_negative_offset
    pc = 0xfd49
    offset = 3

    @processor.pc = pc
    @processor.p = Vic20::Processor::N_FLAG

    @processor.addressing_mode = :relative
    @processor.operand = 0x100 - offset
    @processor.bmi

    assert_equal(pc - offset, @processor.pc)
  end
end
