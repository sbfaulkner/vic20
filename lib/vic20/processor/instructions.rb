module Vic20
  class Processor
    module Instructions
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
        0xBE => { method: :ldx, addressing_mode: :absolute_y,  cycles: 4 },
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

      def operand(bytes)
        case bytes.size
        when 3
          bytes[1] | bytes[2] << 8
        when 2
          bytes[1]
        end
      end

      def relative_operand(bytes)
        value = operand(bytes)
        value > 0x7F ? value - 0x100 : value
      end

      def adc(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :indirect_x
          address = (operand(bytes) + x) & 0xff
          address = @memory[address] | @memory[address + 1] << 8
          @memory[address]
        when :indirect_y
          address = operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        if d?
          lo = (a & 0x0f) + (value & 0x0f) + p[0]
          lo += 6 if lo > 9
          hi = (a & 0xf0) + (value & 0xf0) + (lo & 0xf0)
          hi += 0x60 if hi > 0x90

          result = hi & 0xf0 | lo & 0x0f

          assign_overflow_flag((a ^ result) & (value ^ result) & 0x80 != 0)

          self.a = result

          assign_carry_flag(hi > 0x90)
        else
          result = a + value + p[0]

          assign_overflow_flag((a ^ result) & (value ^ result) & 0x80 != 0)

          self.a = result & 0xff

          assign_carry_flag(result > 0xff)
        end

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def and(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :indirect_x
          address = (operand(bytes) + x) & 0xff
          address = @memory[address] | @memory[address + 1] << 8
          @memory[address]
        when :indirect_y
          address = operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :immediate
        end

        self.a &= value

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def asl(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :accumulator
          a
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          address = (operand(bytes) + x) & 0xff
          @memory[address]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        shifted = value << 1
        value = shifted & 0xff

        case addressing_mode
        when :absolute
          @memory[operand(bytes)] = value
        when :absolute_x
          @memory[operand(bytes) + x] = value
        when :accumulator
          self.a = value
        when :zero_page
          @memory[operand(bytes)] = value
        when :zero_page_x
          address = (operand(bytes) + x) & 0xff
          @memory[address] = value
        end

        assign_carry_flag(shifted & 0x100 != 0)
        affect_sign_flag(value)
        affect_zero_flag(value)
      end

      def bcc(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) unless c?
      end

      def bcs(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) if c?
      end

      def beq(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) if z?
      end

      def bit(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :zero_page
          @memory[operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = a & value

        assign_overflow_flag(value & 0x40 != 0)
        affect_sign_flag(value)
        affect_zero_flag(result)
      end

      def bmi(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) if n?
      end

      def bne(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) unless z?
      end

      def bpl(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) unless n?
      end

      def brk(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        push_word pc + 1
        self.p |= B_FLAG
        push p
        self.p |= I_FLAG
        self.pc = @memory[IRQ_VECTOR] | @memory[IRQ_VECTOR + 1] << 8
      end

      def bvc(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) unless v?
      end

      def bvs(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += relative_operand(bytes) if v?
      end

      def clc(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~C_FLAG
      end

      def cld(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~D_FLAG
      end

      def cli(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~I_FLAG
      end

      def clv(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~V_FLAG
      end

      def cmp(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :indirect_x
          address = (operand(bytes) + x) & 0xff
          address = @memory[address] | @memory[address + 1] << 8
          @memory[address]
        when :indirect_y
          address = operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          address = (operand(bytes) + x) & 0xff
          @memory[address]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = a - value

        assign_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def cpx(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :immediate
          operand(bytes)
        when :zero_page
          @memory[operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = x - value

        assign_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def cpy(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :immediate
          operand(bytes)
        when :zero_page
          @memory[operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = y - value

        assign_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def dec(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        value = (value - 1) & 0xff

        case addressing_mode
        when :absolute
          @memory[operand(bytes)] = value
        when :absolute_x
          @memory[operand(bytes) + x] = value
        when :zero_page
          @memory[operand(bytes)] = value
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff] = value
        end

        affect_sign_flag(value)
        affect_zero_flag(value)
      end

      def dex(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.x = (x - 1) & 0xff

        affect_sign_flag(x)
        affect_zero_flag(x)
      end

      def dey(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.y = (y - 1) & 0xff

        affect_sign_flag(y)
        affect_zero_flag(y)
      end

      def eor(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :indirect_x
          address = (operand(bytes) + x) & 0xff
          address = @memory[address] | @memory[address + 1] << 8
          @memory[address]
        when :indirect_y
          address = operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        self.a ^= value

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def inc(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        value = (value + 1) & 0xff

        case addressing_mode
        when :absolute
          @memory[operand(bytes)] = value
        when :absolute_x
          @memory[operand(bytes) + x] = value
        when :zero_page
          @memory[operand(bytes)] = value
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff] = value
        end

        affect_sign_flag(value)
        affect_zero_flag(value)
      end

      def inx(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.x = (x + 1) & 0xff

        affect_sign_flag(x)
        affect_zero_flag(x)
      end

      def iny(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.y = (y + 1) & 0xff

        affect_sign_flag(y)
        affect_zero_flag(y)
      end

      def jmp(addressing_mode, bytes)
        self.pc = case addressing_mode
        when :absolute
          operand(bytes)
        when :indirect
          address = operand(bytes)
          @memory[address] | @memory[address + 1] << 8
        else
          raise UnsupportedAddressingMode, addressing_mode
        end
      end

      def jsr(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :absolute

        push_word pc - 1
        self.pc = operand(bytes)
      end

      def lda(addressing_mode, bytes)
        self.a = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :indirect_x
          address = (operand(bytes) + x) & 0xff
          address = @memory[address] | @memory[address + 1] << 8
          @memory[address]
        when :indirect_y
          address = operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          address = (operand(bytes) + x) & 0xff
          @memory[address]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def ldx(addressing_mode, bytes)
        self.x = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_y
          address = (operand(bytes) + y) & 0xff
          @memory[address]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(x)
        affect_zero_flag(x)
      end

      def ldy(addressing_mode, bytes)
        self.y = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :immediate
          operand(bytes)
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          address = (operand(bytes) + x) & 0xff
          @memory[address]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(y)
        affect_zero_flag(y)
      end

      def lsr(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :accumulator
          a
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        assign_carry_flag(value & 0x01 != 0)

        result = value >> 1

        case addressing_mode
        when :absolute
          @memory[operand(bytes)] = result
        when :absolute_x
          @memory[operand(bytes) + x] = result
        when :accumulator
          self.a = result
        when :zero_page
          @memory[operand(bytes)] = result
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff] = result
        end

        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def nop(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied
      end

      def ora(addressing_mode, bytes)
        self.a |= case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :indirect_x
          address = (operand(bytes) + x) & 0xff
          address = @memory[address] | @memory[address + 1] << 8
          @memory[address]
        when :indirect_y
          address = operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def pha(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        push a
      end

      def php(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        push p | B_FLAG
      end

      def pla(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.a = pop

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def plp(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p = pop & ~B_FLAG
      end

      def rol(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :accumulator
          a
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        shifted = value << 1

        result = shifted & 0xff
        result |= 0x01 if c?

        case addressing_mode
        when :absolute
          @memory[operand(bytes)] = result
        when :absolute_x
          @memory[operand(bytes) + x] = result
        when :accumulator
          self.a = result
        when :zero_page
          @memory[operand(bytes)] = result
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff] = result
        end

        assign_carry_flag(shifted & 0x100 != 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def ror(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :accumulator
          a
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        shifted = (value << 8) >> 1

        result = shifted >> 8
        result |= 0x80 if c?

        case addressing_mode
        when :absolute
          @memory[operand(bytes)] = result
        when :absolute_x
          @memory[operand(bytes) + x] = result
        when :accumulator
          self.a = result
        when :zero_page
          @memory[operand(bytes)] = result
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff] = result
        end

        assign_carry_flag(shifted & 0x80 != 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def rti(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p = pop & ~B_FLAG
        self.pc = pop_word
      end

      def rts(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.pc = pop_word + 1
      end

      def sbc(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute
          @memory[operand(bytes)]
        when :absolute_x
          @memory[operand(bytes) + x]
        when :absolute_y
          @memory[operand(bytes) + y]
        when :immediate
          operand(bytes)
        when :indirect_x
          address = (operand(bytes) + x) & 0xff
          address = @memory[address] | @memory[address + 1] << 8
          @memory[address]
        when :indirect_y
          address = operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[operand(bytes)]
        when :zero_page_x
          @memory[(operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        if d?
          value = 0x99 - value + 1

          lo = (a & 0x0f) + (value & 0x0f) - (1 - p[0])
          lo += 6 if lo > 9
          hi = (a & 0xf0) + (value & 0xf0) + (lo & 0xf0)
          hi += 0x60 if hi > 0x90

          result = hi & 0xf0 | lo & 0x0f

          assign_overflow_flag((a ^ result) & (value ^ result) & 0x80 != 0)

          self.a = result

          assign_carry_flag(hi > 0x90)
        else
          value = 0xff - value

          result = a + value + p[0]

          assign_overflow_flag((a ^ result) & (value ^ result) & 0x80 != 0)

          self.a = result & 0xff

          assign_carry_flag(result > 0xff)
        end

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def sec(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p |= C_FLAG
      end

      def sed(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p |= D_FLAG
      end

      def sei(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p |= I_FLAG
      end

      def sta(addressing_mode, bytes)
        address = case addressing_mode
        when :absolute
          operand(bytes)
        when :absolute_x
          operand(bytes) + x
        when :absolute_y
          operand(bytes) + y
        when :indirect_x
          source = (operand(bytes) + x) & 0xff
          @memory[source] | @memory[source + 1] << 8
        when :indirect_y
          source = operand(bytes)
          (@memory[source] | @memory[source + 1] << 8) + y
        when :zero_page
          operand(bytes)
        when :zero_page_x
          (operand(bytes) + x) & 0xff
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        @memory[address] = a
      end

      def stx(addressing_mode, bytes)
        address = case addressing_mode
        when :absolute
          operand(bytes)
        when :zero_page
          operand(bytes)
        when :zero_page_y
          (operand(bytes) + y) & 0xff
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        @memory[address] = x
      end

      def sty(addressing_mode, bytes)
        address = case addressing_mode
        when :absolute
          operand(bytes)
        when :zero_page
          operand(bytes)
        when :zero_page_x
          (operand(bytes) + x) & 0xff
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        @memory[address] = y
      end

      def tax(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.x = a

        affect_sign_flag(x)
        affect_zero_flag(x)
      end

      def tay(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.y = a

        affect_sign_flag(y)
        affect_zero_flag(y)
      end

      def tsx(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.x = s

        affect_sign_flag(x)
        affect_zero_flag(x)
      end

      def txa(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.a = x

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def txs(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.s = x
      end

      def tya(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.a = y

        affect_sign_flag(a)
        affect_zero_flag(a)
      end
    end
  end
end
