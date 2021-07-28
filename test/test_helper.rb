# frozen_string_literal: true
$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"
require 'mocha/minitest'

require "pry"
require "vic20"

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

class Vic20::Processor::Test < Minitest::Test
  class Processor < Vic20::Processor
    attr_writer :addressing_mode, :operand

    def initialize(memory, options = {})
      super

      @addressing_mode = :implied
      @operand = nil
    end

    def addressing_mode=(value)
      @addressing_mode = value
    end

    def operand=(value)
      @operand = value
    end
  end

  def setup
    super

    @memory = Vic20::Memory.new
    @processor = Processor.new(@memory)
  end

  private

  def assert_bcd_flag
    assert_predicate(@processor, :d?, "Expected BCD flag to be set")
  end

  def assert_breakpoint_flag
    assert_predicate(@processor, :b?, "Expected breakpoint flag to be set")
  end

  def assert_carry_flag
    assert_predicate(@processor, :c?, "Expected carry flag to be set")
  end

  def assert_interrupt_flag
    assert_predicate(@processor, :i?, "Expected interrupt flag to be set")
  end

  def assert_overflow_flag
    assert_predicate(@processor, :v?, "Expected overflow flag to be set")
  end

  def assert_sign_flag
    assert_predicate(@processor, :n?, "Expected sign flag to be set")
  end

  def assert_zero_flag
    assert_predicate(@processor, :z?, "Expected zero flag to be set")
  end

  def refute_bcd_flag
    refute_predicate(@processor, :d?, "Expected BCD flag to be clear")
  end

  def refute_breakpoint_flag
    refute_predicate(@processor, :b?, "Expected breakpoint flag to be clear")
  end

  def refute_carry_flag
    refute_predicate(@processor, :c?, "Expected carry flag to be clear")
  end

  def refute_interrupt_flag
    refute_predicate(@processor, :i?, "Expected interrupt flag to be clear")
  end

  def refute_overflow_flag
    refute_predicate(@processor, :v?, "Expected overflow flag to be clear")
  end

  def refute_sign_flag
    refute_predicate(@processor, :n?, "Expected sign flag to be clear")
  end

  def refute_zero_flag
    refute_predicate(@processor, :z?, "Expected zero flag to be clear")
  end

  def lsb(word)
    word & 0xff
  end

  def msb(word)
    word >> 8
  end
end
