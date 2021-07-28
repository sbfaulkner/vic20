# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::SEITest < Vic20::Processor::Test
  def test_sets_the_interrupt_flag
    @processor.p = 0x00

    @processor.sei

    assert_interrupt_flag
  end
end
