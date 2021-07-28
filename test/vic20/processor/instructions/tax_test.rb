# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class TAXTest < Vic20::Processor::Test
        def test_transfer_accumulator_to_x_register
          value = 0x0f

          @processor.a = value
          @processor.x = 0xdd
          @processor.p = 0

          @processor.tax

          assert_equal(value, @processor.x)
          refute_sign_flag
          refute_zero_flag
        end

        def test_transfer_accumulator_to_x_register_when_zero
          value = 0

          @processor.a = value
          @processor.x = 0xdd
          @processor.p = 0

          @processor.tax

          refute_sign_flag
          assert_zero_flag
        end

        def test_transfer_accumulator_to_x_register_when_negative
          value = 0xf0

          @processor.a = value
          @processor.x = 0xdd
          @processor.p = 0

          @processor.tax

          assert_sign_flag
          refute_zero_flag
        end
      end
    end
  end
end
