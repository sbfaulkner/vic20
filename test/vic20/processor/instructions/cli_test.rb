# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class CLITest < Vic20::Processor::Test
        def test_clears_the_interrupt_flag
          @processor.p = 0xff

          @processor.cli

          refute_interrupt_flag
        end
      end
    end
  end
end
