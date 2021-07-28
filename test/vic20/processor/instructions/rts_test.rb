# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      class RTSTest < Vic20::Processor::Test
        def test_returns_from_subroutine
          address = 0xfd30

          @processor.push_word(address - 1)
          @processor.pc = 0xfd4d

          @processor.rts

          assert_equal(address, @processor.pc)
        end
      end
    end
  end
end
