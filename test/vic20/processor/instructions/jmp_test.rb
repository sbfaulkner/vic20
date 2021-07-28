# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::JMPTest < Vic20::Processor::Test
  def test_absolute_addressing_mode
    pc = 0xfdd2
    destination = 0xfe7b

    @processor.pc = pc

    @processor.addressing_mode = :absolute
    @processor.operand = destination
    @processor.jmp

    assert_equal(destination, @processor.pc)
  end

  def test_indirect_addressing_mode
    pc = 0xfdd2
    destination = 0xfe7b
    address = 0xc000

    @memory.set_bytes(address, 2, [lsb(destination), msb(destination)])
    @processor.pc = pc

    @processor.addressing_mode = :indirect
    @processor.operand = address
    @processor.jmp

    assert_equal(destination, @processor.pc)
  end
end
