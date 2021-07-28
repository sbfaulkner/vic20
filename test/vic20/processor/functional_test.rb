# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::FunctionalTest < Minitest::Test
  class FunctionalTestSuite < Vic20::Processor
    prepend Vic20::Processor::Halt
    prepend Vic20::Processor::Report

    FIRMWARE_PATH = File.expand_path('../../../firmware/6502_functional_test.bin', __dir__)

    def initialize
      super(Vic20::Memory.new(expansion: 11), pc: 0x0400)

      @memory.load(FIRMWARE_PATH)
    end
  end

  def test_runs_functional_test_suite
    skip unless ENV['SLOW']
    suite = FunctionalTestSuite.new
    assert_equal(0x3399, suite.run)
  end
end
