#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'

ITERATIONS = 1_000_000

class Processor
  def operand(addressing_mode)
    case addressing_mode
    when :absolute
      0xFFFF
    when :immediate
      0xFF
    when :relative
      0x7F
    end
  end

  def absolute_operand
    0xFFFF
  end

  def immediate_operand
    0xFF
  end

  def relative_operand
    0x7F
  end

  def self.instructions
    @instructions ||= {}
  end

  def self.instruction(opcode, options, &block)
    instructions[opcode] = options.merge(
      instance_method: instance_method("#{options[:addressing_mode]}_operand"),
      block: block
    )
  end

  instruction 0, addressing_mode: :relative do
    0x7F
  end
  instruction 1, addressing_mode: :absolute do
    0xFFFF
  end
  instruction 2, addressing_mode: :immediate do
    0xFF
  end

  def initialize
    @instructions = self.class.instructions.dup
    @instructions.each { |_, i| i[:method] = method("#{i[:addressing_mode]}_operand") }
  end

  def each_with_case
    ITERATIONS.times do |i|
      opcode = i % 3
      instruction = self.class.instructions[opcode]
      @operand = operand(instruction[:addressing_mode])
    end
  end

  def each_with_send
    ITERATIONS.times do |i|
      opcode = i % 3
      instruction = self.class.instructions[opcode]
      @operand = send("#{instruction[:addressing_mode]}_operand")
    end
  end

  def each_with_bind_and_call
    ITERATIONS.times do |i|
      opcode = i % 3
      instruction = self.class.instructions[opcode]
      @operand = instruction[:instance_method].bind(self).call
    end
  end

  def each_with_call
    ITERATIONS.times do |i|
      opcode = i % 3
      instruction = self.class.instructions[opcode]
      @operand = instruction[:method].call
    end
  end

  def each_with_instance_eval
    ITERATIONS.times do |i|
      opcode = i % 3
      instruction = self.class.instructions[opcode]
      @operand = instance_eval(&instruction[:block])
    end
  end

  def each_with_instance_exec
    ITERATIONS.times do |i|
      opcode = i % 3
      instruction = self.class.instructions[opcode]
      @operand = instance_exec(&instruction[:block])
    end
  end
end

processor = Processor.new

Benchmark.bm(15) do |x|
  x.report('case:')          { processor.each_with_case }
  x.report('send:')          { processor.each_with_send }
  x.report('bind+call:')     { processor.each_with_bind_and_call }
  x.report('call:')          { processor.each_with_call }
  x.report('instance_eval:') { processor.each_with_instance_eval }
  x.report('instance_exec:') { processor.each_with_instance_eval }
end
