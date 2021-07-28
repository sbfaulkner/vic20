# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class TXSTest < Vic20::Processor::Test
        def test_transfers_the_x_index_register_to_the_stack_pointer
          @processor.s = 0
          @processor.x = 0xff

          @processor.txs

          assert_equal(@processor.s, 0xff)
        end
      end
    end
  end
end
