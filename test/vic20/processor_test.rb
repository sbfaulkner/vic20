# frozen_string_literal: true
require 'test_helper'

class Vic20::ProcessorTest < Minitest::Test
  def test_initializes_pc_using_reset_vector
    default = 0x1234

    memory = Vic20::Memory.new
    memory.set_bytes(Vic20::Memory::RESET_VECTOR, 2, [default & 0xff, default >> 8])

    processor = Vic20::Processor.new(memory)

    assert_equal(default, processor.pc)
  end

  def test_initializes_pc_using_specified_value
    default = 0x1234
    override = 0xbeef

    memory = Vic20::Memory.new
    memory.set_bytes(Vic20::Memory::RESET_VECTOR, 2, [default & 0xff, default >> 8])

    processor = Vic20::Processor.new(memory, pc: override)

    assert_equal(override, processor.pc)
  end

  def test_registers
    memory = Vic20::Memory.new
    processor = Vic20::Processor.new(memory)

    assert_instance_of(Integer, processor.a)
    assert_instance_of(Integer, processor.x)
    assert_instance_of(Integer, processor.y)
  end

  def test_processor_status
    memory = Vic20::Memory.new
    processor = Vic20::Processor.new(memory)

    assert_instance_of(Integer, processor.p)
  end

  def test_processor_status_sets_bit_5
    memory = Vic20::Memory.new
    processor = Vic20::Processor.new(memory)

    processor.p = 0
    assert_equal(1, processor.p[5])
  end

  def test_processor_status_flags_clear
    memory = Vic20::Memory.new
    processor = Vic20::Processor.new(memory)

    processor.p = 0

    refute_predicate(processor, :c?)
    refute_predicate(processor, :z?)
    refute_predicate(processor, :i?)
    refute_predicate(processor, :d?)
    refute_predicate(processor, :b?)
    refute_predicate(processor, :v?)
    refute_predicate(processor, :n?)
  end

  def test_processor_status_flags_set
    memory = Vic20::Memory.new
    processor = Vic20::Processor.new(memory)

    processor.p = 0xff

    assert_predicate(processor, :c?)
    assert_predicate(processor, :z?)
    assert_predicate(processor, :i?)
    assert_predicate(processor, :d?)
    assert_predicate(processor, :b?)
    assert_predicate(processor, :v?)
    assert_predicate(processor, :n?)
  end

  def test_stack_pointer
    memory = Vic20::Memory.new
    processor = Vic20::Processor.new(memory)

    assert_instance_of(Integer, processor.s)
  end

  def test_program_counter
    memory = Vic20::Memory.new
    processor = Vic20::Processor.new(memory)

    assert_instance_of(Integer, processor.pc)
  end
end
