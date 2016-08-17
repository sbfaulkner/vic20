module Vic20
  class Processor
    module Instructions
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
      }

      UNKNOWN_INSTRUCTION = {
        method: '???',
        addressing_mode: :implied,
        cycles: 0,
      }.freeze

      def initialize_instructions
        @instructions = INSTRUCTIONS.each_with_object(Hash.new(UNKNOWN_INSTRUCTION)) do |(opcode, i), instructions|
          instructions[opcode] = i.merge(instruction_method: method(i[:method]))
        end
      end

      def load_operand
        case @addressing_mode
        when :absolute
          @memory.get_byte(@operand)
        when :absolute_x
          @memory.get_byte(@operand + @x)
        when :absolute_y
          @memory.get_byte(@operand + @y)
        when :accumulator
          @a
        when :immediate
          @operand
        when :indirect
          @memory.get_word(@operand)
        when :indirect_x
          @memory.get_byte(@memory.get_word((@operand + @x) & 0xff))
        when :indirect_y
          @memory.get_byte(@memory.get_word(@operand) + @y)
        when :relative
          @operand > 0x7f ? @operand - 0x100 : @operand
        when :zero_page
          @memory.get_byte(@operand)
        when :zero_page_x
          @memory.get_byte((@operand + @x) & 0xff)
        when :zero_page_y
          @memory.get_byte((@operand + @y) & 0xff)
        end
      end

      def store_result(value)
        case @addressing_mode
        when :absolute
          @memory.set_byte(@operand, value)
        when :absolute_x
          @memory.set_byte(@operand + @x, value)
        when :absolute_y
          @memory.set_byte(@operand + @y, value)
        when :accumulator
          @a = value
        when :indirect_x
          @memory.set_byte(@memory.get_word((@operand + @x) & 0xff), value)
        when :indirect_y
          @memory.set_byte(@memory.get_word(@operand) + @y, value)
        when :zero_page
          @memory.set_byte(@operand, value)
        when :zero_page_x
          @memory.set_byte((@operand + @x) & 0xff, value)
        when :zero_page_y
          @memory.set_byte((@operand + @y) & 0xff, value)
        end
      end

      def adc
        value = load_operand

        if d?
          lo = (@a & 0x0f) + (value & 0x0f) + @p[0]
          lo += 6 if lo > 9
          hi = (@a & 0xf0) + (value & 0xf0) + (lo & 0xf0)
          hi += 0x60 if hi > 0x90

          result = hi & 0xf0 | lo & 0x0f

          assign_overflow_flag((@a ^ result) & (value ^ result) & 0x80 != 0)

          @a = result

          assign_carry_flag(hi > 0x90)
        else
          result = @a + value + @p[0]

          assign_overflow_flag((@a ^ result) & (value ^ result) & 0x80 != 0)

          @a = result & 0xff

          assign_carry_flag(result > 0xff)
        end

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def and
        @a &= load_operand

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def asl
        value = load_operand

        shifted = value << 1
        value = shifted & 0xff

        store_result(value)

        assign_carry_flag(shifted & 0x100 != 0)
        affect_sign_flag(value)
        affect_zero_flag(value)
      end

      def bcc
        @pc += load_operand unless c?
      end

      def bcs
        @pc += load_operand if c?
      end

      def beq
        @pc += load_operand if z?
      end

      def bit
        value = load_operand

        result = @a & value

        assign_overflow_flag(value & 0x40 != 0)
        affect_sign_flag(value)
        affect_zero_flag(result)
      end

      def bmi
        @pc += load_operand if n?
      end

      def bne
        @pc += load_operand unless z?
      end

      def bpl
        @pc += load_operand unless n?
      end

      def brk
        push_word @pc + 1
        @p |= B_FLAG
        push @p | 0b00100000
        @p |= I_FLAG
        @pc = @memory.get_word(IRQ_VECTOR)
      end

      def bvc
        @pc += load_operand unless v?
      end

      def bvs
        @pc += load_operand if v?
      end

      def clc
        @p &= ~C_FLAG
      end

      def cld
        @p &= ~D_FLAG
      end

      def cli
        @p &= ~I_FLAG
      end

      def clv
        @p &= ~V_FLAG
      end

      def cmp
        result = @a - load_operand

        assign_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def cpx
        result = @x - load_operand

        assign_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def cpy
        result = @y - load_operand

        assign_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def dec
        value = load_operand

        value = (value - 1) & 0xff

        store_result(value)

        affect_sign_flag(value)
        affect_zero_flag(value)
      end

      def dex
        @x = (@x - 1) & 0xff

        affect_sign_flag(@x)
        affect_zero_flag(@x)
      end

      def dey
        @y = (@y - 1) & 0xff

        affect_sign_flag(@y)
        affect_zero_flag(@y)
      end

      def eor
        @a ^= load_operand

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def inc
        value = load_operand

        value = (value + 1) & 0xff

        store_result(value)

        affect_sign_flag(value)
        affect_zero_flag(value)
      end

      def inx
        @x = (@x + 1) & 0xff

        affect_sign_flag(@x)
        affect_zero_flag(@x)
      end

      def iny
        @y = (@y + 1) & 0xff

        affect_sign_flag(@y)
        affect_zero_flag(@y)
      end

      def jmp
        @pc = case @addressing_mode
        when :absolute
          @operand
        when :indirect
          @memory.get_word(@operand)
        end
      end

      def jsr
        push_word @pc - 1
        @pc = @operand
      end

      def lda
        @a = load_operand

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def ldx
        @x = load_operand

        affect_sign_flag(@x)
        affect_zero_flag(@x)
      end

      def ldy
        @y = load_operand

        affect_sign_flag(@y)
        affect_zero_flag(@y)
      end

      def lsr
        value = load_operand

        assign_carry_flag(value & 0x01 != 0)

        result = value >> 1

        store_result(result)

        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def nop
      end

      def ora
        @a |= load_operand

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def pha
        push @a
      end

      def php
        push @p | 0b00100000 | B_FLAG
      end

      def pla
        @a = pop

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def plp
        @p = pop & ~B_FLAG
      end

      def rol
        value = load_operand << 1

        result = value & 0xff
        result |= 0x01 if c?

        store_result(result)

        assign_carry_flag(value & 0x100 != 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def ror
        value = (load_operand << 8) >> 1

        result = value >> 8
        result |= 0x80 if c?

        store_result(result)

        assign_carry_flag(value & 0x80 != 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def rti
        @p = pop & ~B_FLAG
        @pc = pop_word
      end

      def rts
        @pc = pop_word + 1
      end

      def sbc
        value = load_operand

        if d?
          value = 0x99 - value + 1

          lo = (@a & 0x0f) + (value & 0x0f) - (1 - @p[0])
          lo += 6 if lo > 9
          hi = (@a & 0xf0) + (value & 0xf0) + (lo & 0xf0)
          hi += 0x60 if hi > 0x90

          result = hi & 0xf0 | lo & 0x0f

          assign_overflow_flag((@a ^ result) & (value ^ result) & 0x80 != 0)

          @a = result

          assign_carry_flag(hi > 0x90)
        else
          value = 0xff - value

          result = @a + value + @p[0]

          assign_overflow_flag((@a ^ result) & (value ^ result) & 0x80 != 0)

          @a = result & 0xff

          assign_carry_flag(result > 0xff)
        end

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def sec
        @p |= C_FLAG
      end

      def sed
        @p |= D_FLAG
      end

      def sei
        @p |= I_FLAG
      end

      def sta
        store_result(@a)
      end

      def stx
        store_result(@x)
      end

      def sty
        store_result(@y)
      end

      def tax
        @x = @a

        affect_sign_flag(@x)
        affect_zero_flag(@x)
      end

      def tay
        @y = @a

        affect_sign_flag(@y)
        affect_zero_flag(@y)
      end

      def tsx
        @x = @s

        affect_sign_flag(@x)
        affect_zero_flag(@x)
      end

      def txa
        @a = @x

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end

      def txs
        @s = @x
      end

      def tya
        @a = @y

        affect_sign_flag(@a)
        affect_zero_flag(@a)
      end
    end
  end
end
