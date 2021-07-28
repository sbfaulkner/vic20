# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class DEXTest < Vic20::Processor::Test
        def test_decrement_x_register
          x = 1

          @processor.x = x

          @processor.dex

          assert_equal(x - 1, @processor.x)
          refute_sign_flag
          assert_zero_flag
        end

        def test_decrement_x_register_positive_result
          x = 0x80

          @processor.x = x

          @processor.dex

          assert_equal(x - 1, @processor.x)
          refute_sign_flag
          refute_zero_flag
        end

        def test_decrement_x_register_negative_result
          x = 0

          @processor.x = x

          @processor.dex

          assert_equal(lsb(x - 1), @processor.x)
          assert_sign_flag
          refute_zero_flag
        end
      end
    end
  end
end
