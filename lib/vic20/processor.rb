require_relative 'processor/format'
require_relative 'processor/halt'
require_relative 'processor/instructions'
require_relative 'processor/report'
require_relative 'processor/stack'
require_relative 'processor/trace'

module Vic20
  class Processor
    include Format
    include Instructions
    include Stack

    class Trap < RuntimeError
      def initialize(pc)
        super "Execution halted @ $#{pc.to_s(16).rjust(4, '0')}"
      end
    end

    class UnsupportedAddressingMode < RuntimeError
      def initialize(addressing_mode)
        super "Unsupported addressing mode (#{addressing_mode})"
      end
    end

    NMI_VECTOR    = 0xFFFA
    RESET_VECTOR  = 0xFFFC
    IRQ_VECTOR    = 0xFFFE

    def initialize(memory)
      @memory = memory

      self.pc = 0
      self.a = 0
      self.x = 0
      self.y = 0
      self.p = 0
      self.s = 0
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
          p & #{flag}_FLAG == #{flag}_FLAG
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
        self.p |= C_FLAG
      else
        self.p &= ~C_FLAG
      end
    end

    def assign_overflow_flag(value)
      if value
        self.p |= V_FLAG
      else
        self.p &= ~V_FLAG
      end
    end

    def assign_sign_flag(value)
      if value
        self.p |= N_FLAG
      else
        self.p &= ~N_FLAG
      end
    end

    def assign_zero_flag(value)
      if value
        self.p |= Z_FLAG
      else
        self.p &= ~Z_FLAG
      end
    end

    def current_flags
      Array.new(8) { |i| p[7-i].zero? ? '-' : 'NV?BDIZC'[i] }.join
    end

    def current_state
      format('A=%02X X=%02X Y=%02X P=%s S=%02X PC=%04X', a, x, y, current_flags, s, pc)
    end

    def each
      return enum_for(:each) unless block_given?

      while opcode = @memory[pc]
        instruction = INSTRUCTIONS[opcode] || UNKNOWN_INSTRUCTION
        addressing_mode = instruction[:addressing_mode]
        count = ADDRESSING_MODES[addressing_mode][:bytes]
        address = pc
        self.pc += count
        yield address, instruction[:method], addressing_mode, @memory[address, count]
      end
    end

    def execute(_address, method, addressing_mode, bytes)
      send(method, addressing_mode, bytes)
    end

    def inspect
      format '#<%s:0x%014x %s>', self.class.name, object_id << 1, current_state
    end

    def reset(address = nil)
      self.pc = address || @memory.word_at(RESET_VECTOR)
    end

    def run
      each do |address, method, addressing_mode, bytes|
        execute(address, method, addressing_mode, bytes)
      end
    end
  end
end
