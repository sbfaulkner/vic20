# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class NOPTest < Vic20::Processor::Test
        def test_successful
          @processor.nop
        end
      end
    end
  end
end
