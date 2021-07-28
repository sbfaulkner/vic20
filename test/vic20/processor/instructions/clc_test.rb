# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class CLCTest < Vic20::Processor::Test
        def test_clears_the_carry_flag
          @processor.p = 0xff

          @processor.clc

          refute_carry_flag
        end
      end
    end
  end
end
