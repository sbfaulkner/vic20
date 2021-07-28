# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::Instructions::TXSTest < Vic20::Processor::Test
  def test_transfers_the_x_index_register_to_the_stack_pointer
    @processor.s = 0
    @processor.x = 0xff

    @processor.txs

    assert_equal(@processor.s, 0xff)
  end
end
