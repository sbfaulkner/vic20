# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class TXATest < Vic20::Processor::Test
        def test_transfer_x_register_to_accumulator
          value = 0x0f

          @processor.x = value
          @processor.a = 0xdd
          @processor.p = 0

          @processor.txa

          assert_equal(value, @processor.a)
          refute_sign_flag
          refute_zero_flag
        end

        def test_transfer_x_register_to_accumulator_when_zero
          value = 0

          @processor.x = value
          @processor.a = 0xdd
          @processor.p = 0

          @processor.txa

          refute_sign_flag
          assert_zero_flag
        end

        def test_transfer_x_register_to_accumulator_when_negative
          value = 0xf0

          @processor.x = value
          @processor.a = 0xdd
          @processor.p = 0

          @processor.txa

          assert_sign_flag
          refute_zero_flag
        end
      end
    end
  end
end
