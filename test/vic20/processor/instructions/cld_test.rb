# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::CLDTest < Vic20::Processor::Test
  def test_clears_the_binary_coded_decimal_flag
    @processor.p = 0xff

    @processor.cld

    refute_bcd_flag
  end
end
