require_relative 'register'

module Vic20
  class Processor
    def initialize(memory)
      @memory = memory

      self.a = Register.new
      self.x = Register.new
      self.y = Register.new
      self.p = Register.new
      self.s = Register.new
      self.pc = Register.new
    end

    # https://en.wikipedia.org/wiki/MOS_Technology_6502#Registers
    # The 6502's registers include one 8-bit accumulator register (A),
    # two 8-bit index registers (X and Y), 7 processor status flag bits (P),
    # an 8-bit stack pointer (S), and a 16-bit program counter (PC).
    # The stack's address space is hardwired to memory page $01,
    # i.e. the address range $0100–$01FF (256–511).
    # Software access to the stack is done via four implied addressing mode instructions,
    # whose functions are to push or pop (pull) the accumulator or the processor status register.
    # The same stack is also used for subroutine calls via the JSR (Jump to Subroutine)
    # and RTS (Return from Subroutine) instructions and for interrupt handling.

    attr_accessor :a, :x, :y, :p, :s, :pc

    C_FLAG = 0b00000001 # Carry
    Z_FLAG = 0b00000010 # Zero
    I_FLAG = 0b00000100 # Interrupt
    D_FLAG = 0b00001000 # BCD
    B_FLAG = 0b00010000 # Breakpoint
    V_FLAG = 0b01000000 # Overflow
    N_FLAG = 0b10000000 # Sign

    %i(C Z I D B V N).each do |flag|
      class_eval <<-READER
        def #{flag.downcase}?
          p & #{flag}_FLAG == #{flag}_FLAG
        end
      READER
    end

    def each
      while instruction = @memory[pc]
        yield instruction
      end
    end

    def inspect
      flags = %w(C Z I D B V N).collect { |flag| send("#{flag.downcase}?") ? flag : '.' }.join
      format(
        '#<%s:0x%014x A=%02X X=%02X Y=%02X P=%s S=%02X PC=%04X>',
        self.class.name, object_id << 1,
        a, x, y, flags, s, pc
      )
    end
  end
end
