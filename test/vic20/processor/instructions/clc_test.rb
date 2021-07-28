# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::CLCTest < Vic20::Processor::Test
  def test_clears_the_carry_flag
    @processor.p = 0xff

    @processor.clc

    refute_carry_flag
  end
end
