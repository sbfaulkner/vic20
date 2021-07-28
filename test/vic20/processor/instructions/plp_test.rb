# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::PLPTest < Vic20::Processor::Test
  def test_pull_processor_status
    value = 0b10111101

    @processor.push(value)
    @processor.p = 0

    @processor.plp

    assert_equal(value & Vic20::Processor::B_MASK, @processor.p)
    refute_breakpoint_flag
  end
end
