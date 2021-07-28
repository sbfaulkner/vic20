# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::PHPTest < Vic20::Processor::Test
  def test_processor_status
    value = 0b11000011

    @processor.p = value

    @processor.php

    assert_equal(value | Vic20::Processor::B_FLAG | 0b00100000, @processor.pop)
    assert_equal(value | 0b00100000, @processor.p)
  end
end
