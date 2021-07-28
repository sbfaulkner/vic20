# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class PHATest < Vic20::Processor::Test
        def test_push_accumulator
          value = 0xbd

          @processor.a = value

          @processor.pha

          assert_equal(value, @processor.a)
          assert_equal(value, @processor.pop)
        end
      end
    end
  end
end
