# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::CLITest < Vic20::Processor::Test
  def test_clears_the_interrupt_flag
    @processor.p = 0xff

    @processor.cli

    refute_interrupt_flag
  end
end

