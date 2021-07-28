# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::SEDTest < Vic20::Processor::Test
  def test_sets_the_binary_coded_decimal_flag
    @processor.p = 0x00

    @processor.sed

    assert_bcd_flag
  end
end
