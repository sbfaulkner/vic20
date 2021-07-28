# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::BEQTest < Vic20::Processor::Test
  def test_branches_when_zero_flag_is_set
    pc = 0xfdba
    offset = 3

    @processor.pc = pc
    @processor.p = Vic20::Processor::Z_FLAG

    @processor.addressing_mode = :relative
    @processor.operand = offset
    @processor.beq

    assert_equal(pc + offset, @processor.pc)
  end

  def test_does_not_branch_when_zero_flag_is_clear
    pc = 0xfdba
    offset = 3

    @processor.pc = pc
    @processor.p = 0

    @processor.addressing_mode = :relative
    @processor.operand = offset
    @processor.beq

    assert_equal(pc, @processor.pc)
  end

  def test_branches_backwards_with_a_negative_offset
    pc = 0xfdba
    offset = 3

    @processor.pc = pc
    @processor.p = Vic20::Processor::Z_FLAG

    @processor.addressing_mode = :relative
    @processor.operand = 0x100 - offset
    @processor.beq

    assert_equal(pc - offset, @processor.pc)
  end
end