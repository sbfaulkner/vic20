# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::SECTest < Vic20::Processor::Test
  def test_sets_the_carry_flag
    @processor.p = 0x00

    @processor.sec

    assert_carry_flag
  end
end
