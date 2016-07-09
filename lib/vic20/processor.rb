require_relative 'register'

module Vic20
  class Processor
    NMI_VECTOR    = 0xFFFA
    RESET_VECTOR  = 0xFFFC
    IRQ_VECTOR    = 0xFFFE

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

    ADDRESSING_MODES = {
      absolute: { bytes: 3, format: '$%04X' },
      absolute_x: { bytes: 3, format: '$%04X,X' },
      absolute_y: { bytes: 3, format: '$%04X,Y' },
      accumulator: { bytes: 1, format: 'A' },
      immediate: { bytes: 2, format: '#$%02X' },
      implied: { bytes: 1, format: '' },
      indirect: { bytes: 3, format: '($%02X)' },
      indirect_x: { bytes: 2, format: '($%02X,X)' },
      indirect_y: { bytes: 2, format: '($%02X),Y' },
      relative: { bytes: 2, format: '$%02X' },
      zero_page: { bytes: 2, format: '$%02X' },
      zero_page_x: { bytes: 2, format: '$%02X,X' },
      zero_page_y: { bytes: 2, format: '$%02X,Y' },
    }.freeze

    def self.format_operand(addressing_mode, bytes)
      format Vic20::Processor::ADDRESSING_MODES[addressing_mode][:format], extract_operand(bytes)
    end

    def self.extract_operand(bytes)
      case bytes.size
      when 3
        bytes[1] + bytes[2] * 256
      when 2
        bytes[1]
      end
    end

    INSTRUCTIONS = {
      0x00 => { method: :brk, addressing_mode: :implied,     cycles: 2 },
      0x01 => { method: :ora, addressing_mode: :indirect_x,  cycles: 2 },
      0x05 => { method: :ora, addressing_mode: :zero_page,   cycles: 3 },
      0x06 => { method: :asl, addressing_mode: :zero_page,   cycles: 5 },
      0x08 => { method: :php, addressing_mode: :implied,     cycles: 2 },
      0x09 => { method: :ora, addressing_mode: :immediate,   cycles: 2 },
      0x0A => { method: :asl, addressing_mode: :accumulator, cycles: 2 },
      0x0D => { method: :ora, addressing_mode: :absolute,    cycles: 4 },
      0x0E => { method: :asl, addressing_mode: :absolute,    cycles: 6 },
      0x10 => { method: :bpl, addressing_mode: :relative,    cycles: 2 },
      0x11 => { method: :ora, addressing_mode: :indirect_y,  cycles: 5 },
      0x15 => { method: :ora, addressing_mode: :zero_page_x, cycles: 4 },
      0x16 => { method: :asl, addressing_mode: :zero_page_x, cycles: 6 },
      0x18 => { method: :clc, addressing_mode: :implied,     cycles: 2 },
      0x19 => { method: :ora, addressing_mode: :absolute_y,  cycles: 4 },
      0x1D => { method: :ora, addressing_mode: :absolute_x,  cycles: 4 },
      0x1E => { method: :asl, addressing_mode: :absolute_x,  cycles: 7 },
      0x20 => { method: :jsr, addressing_mode: :absolute,    cycles: 6 },
      0x21 => { method: :and, addressing_mode: :indirect_x,  cycles: 6 },
      0x24 => { method: :bit, addressing_mode: :zero_page,   cycles: 3 },
      0x25 => { method: :and, addressing_mode: :zero_page,   cycles: 3 },
      0x26 => { method: :rol, addressing_mode: :zero_page,   cycles: 5 },
      0x28 => { method: :plp, addressing_mode: :implied,     cycles: 4 },
      0x29 => { method: :and, addressing_mode: :immediate,   cycles: 2 },
      0x2A => { method: :rol, addressing_mode: :accumulator, cycles: 2 },
      0x2C => { method: :bit, addressing_mode: :absolute,    cycles: 4 },
      0x2D => { method: :and, addressing_mode: :absolute,    cycles: 4 },
      0x2E => { method: :rol, addressing_mode: :absolute,    cycles: 6 },
      0x30 => { method: :bmi, addressing_mode: :relative,    cycles: 2 },
      0x31 => { method: :and, addressing_mode: :indirect_y,  cycles: 5 },
      0x35 => { method: :and, addressing_mode: :zero_page_x, cycles: 4 },
      0x36 => { method: :rol, addressing_mode: :zero_page_x, cycles: 6 },
      0x38 => { method: :sec, addressing_mode: :implied,     cycles: 2 },
      0x39 => { method: :and, addressing_mode: :absolute_y,  cycles: 4 },
      0x3D => { method: :and, addressing_mode: :absolute_x,  cycles: 4 },
      0x3E => { method: :rol, addressing_mode: :absolute_x,  cycles: 7 },
      0x40 => { method: :rti, addressing_mode: :implied,     cycles: 6 },
      0x41 => { method: :eor, addressing_mode: :indirect_x,  cycles: 6 },
      0x45 => { method: :eor, addressing_mode: :zero_page,   cycles: 3 },
      0x46 => { method: :lsr, addressing_mode: :zero_page,   cycles: 5 },
      0x48 => { method: :pha, addressing_mode: :implied,     cycles: 3 },
      0x49 => { method: :eor, addressing_mode: :immediate,   cycles: 2 },
      0x4A => { method: :lsr, addressing_mode: :accumulator, cycles: 2 },
      0x4C => { method: :jmp, addressing_mode: :absolute,    cycles: 3 },
      0x4D => { method: :eor, addressing_mode: :absolute,    cycles: 4 },
      0x4E => { method: :lsr, addressing_mode: :absolute,    cycles: 6 },
      0x50 => { method: :bvc, addressing_mode: :relative,    cycles: 2 },
      0x51 => { method: :eor, addressing_mode: :indirect_y,  cycles: 5 },
      0x55 => { method: :eor, addressing_mode: :zero_page_x, cycles: 4 },
      0x56 => { method: :lsr, addressing_mode: :zero_page_x, cycles: 6 },
      0x58 => { method: :cli, addressing_mode: :implied,     cycles: 2 },
      0x59 => { method: :eor, addressing_mode: :absolute_y,  cycles: 4 },
      0x5D => { method: :eor, addressing_mode: :absolute_x,  cycles: 4 },
      0x5E => { method: :lsr, addressing_mode: :absolute_x,  cycles: 7 },
      0x60 => { method: :rts, addressing_mode: :implied,     cycles: 6 },
      0x61 => { method: :adc, addressing_mode: :indirect_x,  cycles: 6 },
      0x65 => { method: :adc, addressing_mode: :zero_page,   cycles: 3 },
      0x66 => { method: :ror, addressing_mode: :zero_page,   cycles: 5 },
      0x68 => { method: :pla, addressing_mode: :implied,     cycles: 4 },
      0x69 => { method: :adc, addressing_mode: :immediate,   cycles: 2 },
      0x6A => { method: :ror, addressing_mode: :accumulator, cycles: 2 },
      0x6C => { method: :jmp, addressing_mode: :indirect,    cycles: 5 },
      0x6D => { method: :adc, addressing_mode: :absolute,    cycles: 4 },
      0x6E => { method: :ror, addressing_mode: :absolute,    cycles: 6 },
      0x70 => { method: :bvs, addressing_mode: :relative,    cycles: 2 },
      0x71 => { method: :adc, addressing_mode: :indirect_y,  cycles: 5 },
      0x75 => { method: :adc, addressing_mode: :zero_page_x, cycles: 4 },
      0x76 => { method: :ror, addressing_mode: :zero_page_x, cycles: 6 },
      0x78 => { method: :sei, addressing_mode: :implied,     cycles: 2 },
      0x79 => { method: :adc, addressing_mode: :absolute_y,  cycles: 4 },
      0x7D => { method: :adc, addressing_mode: :absolute_x,  cycles: 4 },
      0x7E => { method: :ror, addressing_mode: :absolute_x,  cycles: 7 },
      0x81 => { method: :sta, addressing_mode: :indirect_x,  cycles: 6 },
      0x84 => { method: :sty, addressing_mode: :zero_page,   cycles: 3 },
      0x85 => { method: :sta, addressing_mode: :zero_page,   cycles: 3 },
      0x86 => { method: :stx, addressing_mode: :zero_page,   cycles: 3 },
      0x88 => { method: :dey, addressing_mode: :implied,     cycles: 2 },
      0x8A => { method: :txa, addressing_mode: :implied,     cycles: 2 },
      0x8C => { method: :sty, addressing_mode: :absolute,    cycles: 4 },
      0x8D => { method: :sta, addressing_mode: :absolute,    cycles: 4 },
      0x8E => { method: :stx, addressing_mode: :absolute,    cycles: 4 },
      0x90 => { method: :bcc, addressing_mode: :relative,    cycles: 2 },
      0x91 => { method: :sta, addressing_mode: :indirect_y,  cycles: 6 },
      0x94 => { method: :sty, addressing_mode: :zero_page_x, cycles: 4 },
      0x95 => { method: :sta, addressing_mode: :zero_page_x, cycles: 4 },
      0x96 => { method: :stx, addressing_mode: :zero_page_y, cycles: 4 },
      0x98 => { method: :tya, addressing_mode: :implied,     cycles: 2 },
      0x99 => { method: :sta, addressing_mode: :absolute_y,  cycles: 5 },
      0x9A => { method: :txs, addressing_mode: :implied,     cycles: 2 },
      0x9D => { method: :sta, addressing_mode: :absolute_x,  cycles: 5 },
      0xA0 => { method: :ldy, addressing_mode: :immediate,   cycles: 2 },
      0xA1 => { method: :lda, addressing_mode: :indirect_x,  cycles: 6 },
      0xA2 => { method: :ldx, addressing_mode: :immediate,   cycles: 2 },
      0xA4 => { method: :ldy, addressing_mode: :zero_page,   cycles: 3 },
      0xA5 => { method: :lda, addressing_mode: :zero_page,   cycles: 3 },
      0xA6 => { method: :ldx, addressing_mode: :zero_page,   cycles: 3 },
      0xA8 => { method: :tay, addressing_mode: :implied,     cycles: 2 },
      0xA9 => { method: :lda, addressing_mode: :immediate,   cycles: 2 },
      0xAA => { method: :tax, addressing_mode: :implied,     cycles: 2 },
      0xAC => { method: :ldy, addressing_mode: :absolute,    cycles: 4 },
      0xAD => { method: :lda, addressing_mode: :absolute,    cycles: 4 },
      0xAE => { method: :ldx, addressing_mode: :absolute,    cycles: 4 },
      0xB0 => { method: :bcs, addressing_mode: :relative,    cycles: 2 },
      0xB1 => { method: :lda, addressing_mode: :indirect_y,  cycles: 5 },
      0xB4 => { method: :ldy, addressing_mode: :zero_page_x, cycles: 4 },
      0xB5 => { method: :lda, addressing_mode: :zero_page_x, cycles: 4 },
      0xB6 => { method: :ldx, addressing_mode: :zero_page_y, cycles: 4 },
      0xB8 => { method: :clv, addressing_mode: :implied,     cycles: 2 },
      0xB9 => { method: :lda, addressing_mode: :absolute_y,  cycles: 4 },
      0xBA => { method: :tsx, addressing_mode: :implied,     cycles: 2 },
      0xBC => { method: :ldy, addressing_mode: :absolute_x,  cycles: 4 },
      0xBD => { method: :lda, addressing_mode: :absolute_x,  cycles: 4 },
      0xC0 => { method: :cpy, addressing_mode: :immediate,   cycles: 2 },
      0xC1 => { method: :cmp, addressing_mode: :indirect_x,  cycles: 6 },
      0xC4 => { method: :cpy, addressing_mode: :zero_page,   cycles: 3 },
      0xC5 => { method: :cmp, addressing_mode: :zero_page,   cycles: 3 },
      0xC6 => { method: :dec, addressing_mode: :zero_page,   cycles: 5 },
      0xC8 => { method: :iny, addressing_mode: :implied,     cycles: 2 },
      0xC9 => { method: :cmp, addressing_mode: :immediate,   cycles: 2 },
      0xCA => { method: :dex, addressing_mode: :implied,     cycles: 2 },
      0xCC => { method: :cpy, addressing_mode: :absolute,    cycles: 4 },
      0xCD => { method: :cmp, addressing_mode: :absolute,    cycles: 4 },
      0xCE => { method: :dec, addressing_mode: :absolute,    cycles: 6 },
      0xD0 => { method: :bne, addressing_mode: :relative,    cycles: 2 },
      0xD1 => { method: :cmp, addressing_mode: :indirect_y,  cycles: 5 },
      0xD5 => { method: :cmp, addressing_mode: :zero_page_x, cycles: 4 },
      0xD6 => { method: :dec, addressing_mode: :zero_page_x, cycles: 6 },
      0xD8 => { method: :cld, addressing_mode: :implied,     cycles: 2 },
      0xD9 => { method: :cmp, addressing_mode: :absolute_y,  cycles: 4 },
      0xDD => { method: :cmp, addressing_mode: :absolute_x,  cycles: 4 },
      0xDE => { method: :dec, addressing_mode: :absolute_x,  cycles: 7 },
      0xE0 => { method: :cpx, addressing_mode: :immediate,   cycles: 2 },
      0xE1 => { method: :sbc, addressing_mode: :indirect_x,  cycles: 6 },
      0xE4 => { method: :cpx, addressing_mode: :zero_page,   cycles: 3 },
      0xE5 => { method: :sbc, addressing_mode: :zero_page,   cycles: 3 },
      0xE6 => { method: :inc, addressing_mode: :zero_page,   cycles: 5 },
      0xE8 => { method: :inx, addressing_mode: :implied,     cycles: 2 },
      0xE9 => { method: :sbc, addressing_mode: :immediate,   cycles: 2 },
      0xEA => { method: :nop, addressing_mode: :implied,     cycles: 2 },
      0xEC => { method: :cpx, addressing_mode: :absolute,    cycles: 4 },
      0xED => { method: :sbc, addressing_mode: :absolute,    cycles: 4 },
      0xEE => { method: :inc, addressing_mode: :absolute,    cycles: 6 },
      0xF0 => { method: :beq, addressing_mode: :relative,    cycles: 2 },
      0xF1 => { method: :sbc, addressing_mode: :indirect_y,  cycles: 5 },
      0xF5 => { method: :sbc, addressing_mode: :zero_page_x, cycles: 4 },
      0xF6 => { method: :inc, addressing_mode: :zero_page_x, cycles: 6 },
      0xF8 => { method: :sed, addressing_mode: :implied,     cycles: 2 },
      0xF9 => { method: :sbc, addressing_mode: :absolute_y,  cycles: 4 },
      0xFD => { method: :sbc, addressing_mode: :absolute_x,  cycles: 4 },
      0xFE => { method: :inc, addressing_mode: :absolute_x,  cycles: 7 },
    }.freeze

    UNKNOWN_INSTRUCTION = {
      method: '???',
      addressing_mode: :implied,
      cycles: 0,
    }.freeze

    def current_flags
      %w(C Z I D B V N).collect { |flag| send("#{flag.downcase}?") ? flag : '.' }.join
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

    def inspect
      format '#<%s:0x%014x %s>', self.class.name, object_id << 1, current_state
    end

    def pop
    end

    def push(byte)
    end

    def reset
      self.pc = @memory.word_at(RESET_VECTOR)
    end

    # def jsr(addressing_mode, bytes)
    #   case addressing_mode
    #   when :absolute
    #     STDERR.puts "JSR #{self.class.extract_operand(bytes)}"
    #   else
    #     raise "Unsupported addressing mode: #{addressing_mode}"
    #   end
    # end
  end
end
