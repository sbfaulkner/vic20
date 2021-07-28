# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::NOPTest < Vic20::Processor::Test
  def test_successful
    @processor.nop
  end
end
