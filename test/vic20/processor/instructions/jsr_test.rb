# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::JSRTest < Vic20::Processor::Test
  def test_jump_to_subroutine
    pc = 0xfd27
    destination = 0xfd3f

    @processor.pc = pc

    @processor.addressing_mode = :absolute
    @processor.operand = destination
    @processor.jsr

    assert_equal(pc - 1, @processor.pop_word)
    assert_equal(destination, @processor.pc)
  end
end
