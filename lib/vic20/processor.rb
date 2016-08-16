require_relative 'processor/format'
require_relative 'processor/halt'
require_relative 'processor/instructions'
require_relative 'processor/profile'
require_relative 'processor/report'
require_relative 'processor/stack'
require_relative 'processor/trace'

module Vic20
  class Processor
    include Stack
    include Instructions
    include Format

    class Trap < RuntimeError
      def initialize(pc)
        super "Execution halted @ $#{pc.to_s(16).rjust(4, '0')}"
      end
    end

    NMI_VECTOR    = 0xFFFA
    RESET_VECTOR  = 0xFFFC
    IRQ_VECTOR    = 0xFFFE

    def initialize(memory)
      initialize_instructions

      @memory = memory

      @pc = 0
      @a = 0
      @x = 0
      @y = 0
      @p = 0
      @s = 0
    end

    C_FLAG = 0b00000001 # Carry
    Z_FLAG = 0b00000010 # Zero
    I_FLAG = 0b00000100 # Interrupt
    D_FLAG = 0b00001000 # BCD
    B_FLAG = 0b00010000 # Breakpoint
    V_FLAG = 0b01000000 # Overflow
    N_FLAG = 0b10000000 # Sign

    attr_accessor :a, :x, :y, :s, :pc
    attr_reader :p

    def p=(value)
      @p = value | 0b00100000 # 5th bit is always set
    end

    %i(C Z I D B V N).each do |flag|
      class_eval <<-READER
        def #{flag.downcase}?
          @p & #{flag}_FLAG == #{flag}_FLAG
        end
      READER
    end

    def affect_sign_flag(value)
      assign_sign_flag(value & N_FLAG == N_FLAG)
    end

    def affect_zero_flag(value)
      assign_zero_flag(value.zero?)
    end

    def assign_carry_flag(value)
      if value
        @p |= C_FLAG
      else
        @p &= ~C_FLAG
      end
    end

    def assign_overflow_flag(value)
      if value
        @p |= V_FLAG
      else
        @p &= ~V_FLAG
      end
    end

    def assign_sign_flag(value)
      if value
        @p |= N_FLAG
      else
        @p &= ~N_FLAG
      end
    end

    def assign_zero_flag(value)
      if value
        @p |= Z_FLAG
      else
        @p &= ~Z_FLAG
      end
    end

    def current_flags
      Array.new(8) { |i| @p[7-i] == 1 ? 'NV?BDIZC'[i] : '-' }.join
    end

    def current_state
      format('A=%02X X=%02X Y=%02X P=%s S=%02X PC=%04X', @a, @x, @y, current_flags, @s, @pc)
    end

    def each
      return enum_for(:each) unless block_given?

      loop do
        yield @pc, fetch_instruction
      end
    end

    def execute(_address, instruction)
      instruction[:instruction_method].call
    end

    def fetch_instruction
      @opcode = fetch_byte

      instruction = @instructions[@opcode]

      @addressing_mode = instruction[:addressing_mode]

      @operand = fetch_operand

      instruction
    end

    def fetch_byte
      byte = @memory[@pc]
      @pc += 1
      byte
    end

    def fetch_operand
      case @addressing_mode
      when :immediate, :indirect_x, :indirect_y, :relative, :zero_page, :zero_page_x, :zero_page_y
        fetch_byte
      when :absolute, :absolute_x, :absolute_y, :indirect
        fetch_word
      end
    end

    def fetch_word
      word = @memory.word_at(@pc)
      @pc += 2
      word
    end

    def inspect
      format '#<%s:0x%014x %s>', self.class.name, object_id << 1, current_state
    end

    def reset(address = nil)
      @pc = address || @memory.word_at(RESET_VECTOR)
    end

    def run
      each do |address, instruction|
        execute(address, instruction)
      end
    end
  end
end
