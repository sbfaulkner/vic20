# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class CLVTest < Vic20::Processor::Test
        def test_clears_the_overflow_flag
          @processor.p = 0xff

          @processor.clv

          refute_overflow_flag
        end
      end
    end
  end
end
