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

    INSTRUCTIONS = {
      0x00 => { method: :brk, addressing_mode: :implied,     cycles: 2 },
      0x01 => { method: :ora, addressing_mode: :indirect_x,  cycles: 2 }, # TODO: implement ORA (indirect_x)
      0x05 => { method: :ora, addressing_mode: :zero_page,   cycles: 3 }, # TODO: implement ORA (zero_page)
      0x06 => { method: :asl, addressing_mode: :zero_page,   cycles: 5 }, # TODO: implement ASL (zero_page)
      0x08 => { method: :php, addressing_mode: :implied,     cycles: 2 },
      0x09 => { method: :ora, addressing_mode: :immediate,   cycles: 2 },
      0x0A => { method: :asl, addressing_mode: :accumulator, cycles: 2 },
      0x0D => { method: :ora, addressing_mode: :absolute,    cycles: 4 },
      0x0E => { method: :asl, addressing_mode: :absolute,    cycles: 6 }, # TODO: implement ASL (absolute)
      0x10 => { method: :bpl, addressing_mode: :relative,    cycles: 2 },
      0x11 => { method: :ora, addressing_mode: :indirect_y,  cycles: 5 }, # TODO: implement ORA (indirect_y)
      0x15 => { method: :ora, addressing_mode: :zero_page_x, cycles: 4 }, # TODO: implement ORA (zero_page_x)
      0x16 => { method: :asl, addressing_mode: :zero_page_x, cycles: 6 },
      0x18 => { method: :clc, addressing_mode: :implied,     cycles: 2 },
      0x19 => { method: :ora, addressing_mode: :absolute_y,  cycles: 4 }, # TODO: implement ORA (absolute_y)
      0x1D => { method: :ora, addressing_mode: :absolute_x,  cycles: 4 }, # TODO: implement ORA (absolute_x)
      0x1E => { method: :asl, addressing_mode: :absolute_x,  cycles: 7 }, # TODO: implement ASL (absolute_x)
      0x20 => { method: :jsr, addressing_mode: :absolute,    cycles: 6 },
      0x21 => { method: :and, addressing_mode: :indirect_x,  cycles: 6 }, # TODO: implement AND (indirect_x)
      0x24 => { method: :bit, addressing_mode: :zero_page,   cycles: 3 }, # TODO: implement BIT (zero_page)
      0x25 => { method: :and, addressing_mode: :zero_page,   cycles: 3 }, # TODO: implement AND (zero_page)
      0x26 => { method: :rol, addressing_mode: :zero_page,   cycles: 5 }, # TODO: implement ROL (zero_page)
      0x28 => { method: :plp, addressing_mode: :implied,     cycles: 4 },
      0x29 => { method: :and, addressing_mode: :immediate,   cycles: 2 },
      0x2A => { method: :rol, addressing_mode: :accumulator, cycles: 2 }, # TODO: implement ROL (accumulator)
      0x2C => { method: :bit, addressing_mode: :absolute,    cycles: 4 }, # TODO: implement BIT (absolute)
      0x2D => { method: :and, addressing_mode: :absolute,    cycles: 4 }, # TODO: implement AND (absolute)
      0x2E => { method: :rol, addressing_mode: :absolute,    cycles: 6 }, # TODO: implement ROL (absolute)
      0x30 => { method: :bmi, addressing_mode: :relative,    cycles: 2 },
      0x31 => { method: :and, addressing_mode: :indirect_y,  cycles: 5 }, # TODO: implement AND (indirect_y)
      0x35 => { method: :and, addressing_mode: :zero_page_x, cycles: 4 }, # TODO: implement AND (zero_page_x)
      0x36 => { method: :rol, addressing_mode: :zero_page_x, cycles: 6 }, # TODO: implement ROL (zero_page_x)
      0x38 => { method: :sec, addressing_mode: :implied,     cycles: 2 },
      0x39 => { method: :and, addressing_mode: :absolute_y,  cycles: 4 }, # TODO: implement AND (absolute_y)
      0x3D => { method: :and, addressing_mode: :absolute_x,  cycles: 4 }, # TODO: implement AND (absolute_x)
      0x3E => { method: :rol, addressing_mode: :absolute_x,  cycles: 7 }, # TODO: implement ROL (absolute_x)
      0x40 => { method: :rti, addressing_mode: :implied,     cycles: 6 },
      0x41 => { method: :eor, addressing_mode: :indirect_x,  cycles: 6 }, # TODO: implement EOR (indirect_x)
      0x45 => { method: :eor, addressing_mode: :zero_page,   cycles: 3 }, # TODO: implement EOR (zero_page)
      0x46 => { method: :lsr, addressing_mode: :zero_page,   cycles: 5 }, # TODO: implement LSR (zero_page)
      0x48 => { method: :pha, addressing_mode: :implied,     cycles: 3 },
      0x49 => { method: :eor, addressing_mode: :immediate,   cycles: 2 },
      0x4A => { method: :lsr, addressing_mode: :accumulator, cycles: 2 }, # TODO: implement LSR (accumulator)
      0x4C => { method: :jmp, addressing_mode: :absolute,    cycles: 3 },
      0x4D => { method: :eor, addressing_mode: :absolute,    cycles: 4 }, # TODO: implement EOR (absolute)
      0x4E => { method: :lsr, addressing_mode: :absolute,    cycles: 6 }, # TODO: implement LSR (absolute)
      0x50 => { method: :bvc, addressing_mode: :relative,    cycles: 2 },
      0x51 => { method: :eor, addressing_mode: :indirect_y,  cycles: 5 }, # TODO: implement EOR (indirect_y)
      0x55 => { method: :eor, addressing_mode: :zero_page_x, cycles: 4 },
      0x56 => { method: :lsr, addressing_mode: :zero_page_x, cycles: 6 }, # TODO: implement LSR (zero_page_x)
      0x58 => { method: :cli, addressing_mode: :implied,     cycles: 2 },
      0x59 => { method: :eor, addressing_mode: :absolute_y,  cycles: 4 }, # TODO: implement EOR (absolute_y)
      0x5D => { method: :eor, addressing_mode: :absolute_x,  cycles: 4 }, # TODO: implement EOR (absolute_x)
      0x5E => { method: :lsr, addressing_mode: :absolute_x,  cycles: 7 }, # TODO: implement LSR (absolute_x)
      0x60 => { method: :rts, addressing_mode: :implied,     cycles: 6 },
      0x61 => { method: :adc, addressing_mode: :indirect_x,  cycles: 6 }, # TODO: implement ADC (indirect_x)
      0x65 => { method: :adc, addressing_mode: :zero_page,   cycles: 3 },
      0x66 => { method: :ror, addressing_mode: :zero_page,   cycles: 5 }, # TODO: implement ROR (zero_page)
      0x68 => { method: :pla, addressing_mode: :implied,     cycles: 4 },
      0x69 => { method: :adc, addressing_mode: :immediate,   cycles: 2 },
      0x6A => { method: :ror, addressing_mode: :accumulator, cycles: 2 },
      0x6C => { method: :jmp, addressing_mode: :indirect,    cycles: 5 },
      0x6D => { method: :adc, addressing_mode: :absolute,    cycles: 4 }, # TODO: implement ADC (absolute)
      0x6E => { method: :ror, addressing_mode: :absolute,    cycles: 6 }, # TODO: implement ROR (absolute)
      0x70 => { method: :bvs, addressing_mode: :relative,    cycles: 2 },
      0x71 => { method: :adc, addressing_mode: :indirect_y,  cycles: 5 }, # TODO: implement ADC (indirect_y)
      0x75 => { method: :adc, addressing_mode: :zero_page_x, cycles: 4 }, # TODO: implement ADC (zero_page_x)
      0x76 => { method: :ror, addressing_mode: :zero_page_x, cycles: 6 }, # TODO: implement ROR (zero_page_x)
      0x78 => { method: :sei, addressing_mode: :implied,     cycles: 2 },
      0x79 => { method: :adc, addressing_mode: :absolute_y,  cycles: 4 }, # TODO: implement ADC (absolute_y)
      0x7D => { method: :adc, addressing_mode: :absolute_x,  cycles: 4 }, # TODO: implement ADC (absolute_x)
      0x7E => { method: :ror, addressing_mode: :absolute_x,  cycles: 7 }, # TODO: implement ROR (absolute_x)
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
      0xBE => { method: :ldx, addressing_mode: :absolute_y,  cycles: 4 },
      0xC0 => { method: :cpy, addressing_mode: :immediate,   cycles: 2 },
      0xC1 => { method: :cmp, addressing_mode: :indirect_x,  cycles: 6 }, # TODO: implement CMP (indirect_x)
      0xC4 => { method: :cpy, addressing_mode: :zero_page,   cycles: 3 },
      0xC5 => { method: :cmp, addressing_mode: :zero_page,   cycles: 3 },
      0xC6 => { method: :dec, addressing_mode: :zero_page,   cycles: 5 }, # TODO: implement DEC (zero_page)
      0xC8 => { method: :iny, addressing_mode: :implied,     cycles: 2 },
      0xC9 => { method: :cmp, addressing_mode: :immediate,   cycles: 2 },
      0xCA => { method: :dex, addressing_mode: :implied,     cycles: 2 },
      0xCC => { method: :cpy, addressing_mode: :absolute,    cycles: 4 },
      0xCD => { method: :cmp, addressing_mode: :absolute,    cycles: 4 },
      0xCE => { method: :dec, addressing_mode: :absolute,    cycles: 6 }, # TODO: implement DEC (absolute)
      0xD0 => { method: :bne, addressing_mode: :relative,    cycles: 2 },
      0xD1 => { method: :cmp, addressing_mode: :indirect_y,  cycles: 5 },
      0xD5 => { method: :cmp, addressing_mode: :zero_page_x, cycles: 4 },
      0xD6 => { method: :dec, addressing_mode: :zero_page_x, cycles: 6 }, # TODO: implement DEC (zero_page_x)
      0xD8 => { method: :cld, addressing_mode: :implied,     cycles: 2 },
      0xD9 => { method: :cmp, addressing_mode: :absolute_y,  cycles: 4 },
      0xDD => { method: :cmp, addressing_mode: :absolute_x,  cycles: 4 },
      0xDE => { method: :dec, addressing_mode: :absolute_x,  cycles: 7 }, # TODO: implement DEC (absolute_x)
      0xE0 => { method: :cpx, addressing_mode: :immediate,   cycles: 2 },
      0xE1 => { method: :sbc, addressing_mode: :indirect_x,  cycles: 6 }, # TODO: implement SBC (indirect_x)
      0xE4 => { method: :cpx, addressing_mode: :zero_page,   cycles: 3 },
      0xE5 => { method: :sbc, addressing_mode: :zero_page,   cycles: 3 }, # TODO: implement SBC (zero_page)
      0xE6 => { method: :inc, addressing_mode: :zero_page,   cycles: 5 },
      0xE8 => { method: :inx, addressing_mode: :implied,     cycles: 2 },
      0xE9 => { method: :sbc, addressing_mode: :immediate,   cycles: 2 },
      0xEA => { method: :nop, addressing_mode: :implied,     cycles: 2 },
      0xEC => { method: :cpx, addressing_mode: :absolute,    cycles: 4 },
      0xED => { method: :sbc, addressing_mode: :absolute,    cycles: 4 }, # TODO: implement SBC (absolute)
      0xEE => { method: :inc, addressing_mode: :absolute,    cycles: 6 }, # TODO: implement INC (absolute)
      0xF0 => { method: :beq, addressing_mode: :relative,    cycles: 2 },
      0xF1 => { method: :sbc, addressing_mode: :indirect_y,  cycles: 5 }, # TODO: implement SBC (indirect_y)
      0xF5 => { method: :sbc, addressing_mode: :zero_page_x, cycles: 4 }, # TODO: implement SBC (zero_page_x)
      0xF6 => { method: :inc, addressing_mode: :zero_page_x, cycles: 6 }, # TODO: implement INC (zero_page_x)
      0xF8 => { method: :sed, addressing_mode: :implied,     cycles: 2 },
      0xF9 => { method: :sbc, addressing_mode: :absolute_y,  cycles: 4 }, # TODO: implement SBC (absolute_y)
      0xFD => { method: :sbc, addressing_mode: :absolute_x,  cycles: 4 }, # TODO: implement SBC (absolute_x)
      0xFE => { method: :inc, addressing_mode: :absolute_x,  cycles: 7 }, # TODO: implement INC (absolute_x)
    }.freeze

    UNKNOWN_INSTRUCTION = {
      method: '???',
      addressing_mode: :implied,
      cycles: 0,
    }.freeze

    def affect_carry_flag(value)
      if value
        self.p |= C_FLAG
      else
        self.p &= ~C_FLAG
      end
    end

    def affect_sign_flag(value)
      if (value & 0x80) == 0x80
        self.p |= N_FLAG
      else
        self.p &= ~N_FLAG
      end
    end

    def affect_zero_flag(value)
      if value.zero?
        self.p |= Z_FLAG
      else
        self.p &= ~Z_FLAG
      end
    end

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
