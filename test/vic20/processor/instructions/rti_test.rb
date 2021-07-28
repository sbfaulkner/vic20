# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::RTITest < Vic20::Processor::Test
  def test_return_from_interrupt
    pc = 0x0984
    irq = 0xdead
    p = Vic20::Processor::Z_FLAG | Vic20::Processor::B_FLAG

    @processor.p = p
    @processor.push_word(pc)
    @processor.push(@processor.p)

    @processor.pc = irq

    @processor.rti

    assert_equal(p & Vic20::Processor::B_MASK, @processor.p & 0b11011111)
    assert_equal(pc, @processor.pc)
    refute_breakpoint_flag
  end
end
