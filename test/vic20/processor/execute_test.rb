# frozen_string_literal: true
require 'test_helper'

class Vic20::Processor::ExecuteTest < Minitest::Test
  class Runner < Vic20::Processor
    prepend Vic20::Processor::Halt

    def initialize
      super(Vic20::Memory.new, pc: 0x0600)

      [
        [0x0600, [0x20, 0x09, 0x06]], # JSR $0609
        [0x0603, [0x20, 0x0c, 0x06]], # JSR $060c
        [0x0606, [0x20, 0x12, 0x06]], # JSR $0612
        [0x0609, [0xa2, 0x00]],       # LDX #$00
        [0x060b, [0x60]],             # RTS
        [0x060c, [0xe8]],             # INX
        [0x060d, [0xe0, 0x05]],       # CPX #$05
        [0x060f, [0xd0, 0xfb]],       # BNE $060c
        [0x0611, [0x60]],             # RTS
        [0x0612, [0x4c, 0x12, 0x06]], # JMP $0612
      ].each do |address, instruction|
        @memory.set_bytes(address, instruction.size, instruction)
      end
    end
  end

  def setup
    super
    @runner = Runner.new
  end

  def test_run
    @runner.run

    assert_equal(0x0612, @runner.pc)
    assert_equal(5, @runner.x)
  end

  def test_tick
    21.times { @runner.tick }

    assert_equal(0x0612, @runner.pc)
    assert_equal(5, @runner.x)
  end
end
