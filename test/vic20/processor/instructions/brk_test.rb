# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::BRKTest < Vic20::Processor::Test
  def test_interrupts_execution
    pc = 0x0982
    p = Vic20::Processor::Z_FLAG
    top = 0x1ff
    irq = 0xdead

    @memory.set_bytes(0xfffe, 2, [lsb(irq), msb(irq)])
    @processor.s = lsb(top)
    @processor.pc = pc
    @processor.p = p

    @processor.brk

    assert_equal(p | Vic20::Processor::B_FLAG, @processor.pop & 0b11011111)
    assert_equal(pc + 1, @processor.pop_word)
    assert_equal(irq, @processor.pc)
    assert_breakpoint_flag
    assert_interrupt_flag
  end
end
