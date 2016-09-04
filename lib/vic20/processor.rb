require_relative 'processor/breakpoints'
require_relative 'processor/format'
require_relative 'processor/halt'
require_relative 'processor/instructions'
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

    C_MASK = ~C_FLAG & 0xff
    Z_MASK = ~Z_FLAG & 0xff
    I_MASK = ~I_FLAG & 0xff
    D_MASK = ~D_FLAG & 0xff
    B_MASK = ~B_FLAG & 0xff
    V_MASK = ~V_FLAG & 0xff
    N_MASK = ~N_FLAG & 0xff

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
      @p = if value & N_FLAG == N_FLAG
        @p | N_FLAG
      else
        @p & N_MASK
      end
    end

    def affect_zero_flag(value)
      @p = if value.zero?
        @p | Z_FLAG
      else
        @p & Z_MASK
      end
    end

    def assign_carry_flag(value)
      @p = if value
        @p | C_FLAG
      else
        @p & C_MASK
      end
    end

    def assign_overflow_flag(value)
      @p = if value
        @p | V_FLAG
      else
        @p & V_MASK
      end
    end

    def current_flags
      Array.new(8) { |i| @p[7-i] == 1 ? 'NV?BDIZC'[i] : '-' }.join
    end

    def current_state
      format('A=%02X X=%02X Y=%02X P=%s S=%02X PC=%04X', @a, @x, @y, current_flags, @s, @pc)
    end

    def execute(_address, instruction)
      instruction[:instruction_method].call
    end

    def fetch_byte
      byte = @memory.get_byte(@pc)
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
      word = @memory.get_word(@pc)
      @pc += 2
      word
    end

    def inspect
      format '#<%s:0x%014x %s>', self.class.name, object_id << 1, current_state
    end

    def reset(address = nil)
      @pc = address || @memory.get_word(RESET_VECTOR)
    end

    def run
      loop do
        tick
      end
    rescue Vic20::Processor::Trap => e
      return @pc
    end

    def tick
      pc = @pc

      @opcode = fetch_byte

      instruction = @instructions[@opcode]

      @addressing_mode = instruction[:addressing_mode]

      @operand = fetch_operand

      execute(pc, instruction)

      instruction[:cycles]
    end
  end
end
