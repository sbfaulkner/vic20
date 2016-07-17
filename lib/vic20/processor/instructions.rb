module Vic20
  class Processor
    module Instructions
      module ClassMethods
        def format_operand(addressing_mode, bytes)
          format Vic20::Processor::ADDRESSING_MODES[addressing_mode][:format], operand(bytes)
        end

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
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      class UnsupportedAddressingMode < RuntimeError
        def initialize(addressing_mode)
          super "Unsupported addressing mode (#{addressing_mode})"
        end
      end

      def adc(addressing_mode, bytes)
        value = case addressing_mode
        when :immediate
          self.class.operand(bytes)
        when :zero_page
          @memory[self.class.operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = a + value

        self.a = result & 0xff

        affect_carry_flag(result > 0xff)
        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def and(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :immediate

        self.a &= self.class.operand(bytes)

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def asl(addressing_mode, bytes)
        value = case addressing_mode
        when :accumulator
          a
        when :zero_page_x
          @memory[self.class.operand(bytes) + x]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        shifted = value << 1
        value = shifted & 0xff

        case addressing_mode
        when :accumulator
          self.a = value
        when :zero_page_x
          @memory[self.class.operand(bytes) + x] = value
        end

        affect_carry_flag(shifted & 0x100 != 0)
        affect_sign_flag(value)
        affect_zero_flag(value)
      end

      def bcc(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += self.class.relative_operand(bytes) unless c?
      end

      def bcs(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += self.class.relative_operand(bytes) if c?
      end

      def beq(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += self.class.relative_operand(bytes) if z?
      end

      def bmi(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += self.class.relative_operand(bytes) if n?
      end

      def bne(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += self.class.relative_operand(bytes) unless z?
      end

      def bpl(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += self.class.relative_operand(bytes) unless n?
      end

      def cld(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~D_FLAG
      end

      def clc(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~C_FLAG
      end

      def cli(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~I_FLAG
      end

      def cmp(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute_x
          @memory[self.class.operand(bytes) + x]
        when :immediate
          self.class.operand(bytes)
        when :indirect_y
          address = self.class.operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[self.class.operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = a - value

        affect_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def cpx(addressing_mode, bytes)
        value = case addressing_mode
        when :immediate
          self.class.operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = x - value

        affect_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def cpy(addressing_mode, bytes)
        value = case addressing_mode
        when :immediate
          self.class.operand(bytes)
        when :zero_page
          @memory[self.class.operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = y - value

        affect_carry_flag(result >= 0)
        affect_sign_flag(result)
        affect_zero_flag(result)
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
        when :immediate
          self.class.operand(bytes)
        when :zero_page_x
          @memory[(self.class.operand(bytes) + x) & 0xff]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        self.a ^= value

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def inc(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :zero_page

        address = self.class.operand(bytes)

        result = @memory[address] = (@memory[address] + 1) & 0xff

        affect_sign_flag(result)
        affect_zero_flag(result)
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
          self.class.operand(bytes)
        when :indirect
          address = self.class.operand(bytes)
          @memory[address] | @memory[address + 1] << 8
        else
          raise UnsupportedAddressingMode, addressing_mode
        end
      end

      def jsr(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :absolute

        push_word pc - 1
        self.pc = self.class.operand(bytes)
      end

      def lda(addressing_mode, bytes)
        self.a = case addressing_mode
        when :absolute
          @memory[self.class.operand(bytes)]
        when :absolute_x
          @memory[self.class.operand(bytes) + x]
        when :absolute_y
          @memory[self.class.operand(bytes) + y]
        when :immediate
          self.class.operand(bytes)
        when :indirect_y
          address = self.class.operand(bytes)
          address = (@memory[address] | @memory[address + 1] << 8) + y
          @memory[address]
        when :zero_page
          @memory[self.class.operand(bytes)]
        when :zero_page_x
          @memory[self.class.operand(bytes) + x]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def ldx(addressing_mode, bytes)
        self.x = case addressing_mode
        when :absolute
          @memory[self.class.operand(bytes)]
        when :immediate
          self.class.operand(bytes)
        when :zero_page
          @memory[self.class.operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(x)
        affect_zero_flag(x)
      end

      def ldy(addressing_mode, bytes)
        self.y = case addressing_mode
        when :absolute
          @memory[self.class.operand(bytes)]
        when :immediate
          self.class.operand(bytes)
        when :zero_page
          @memory[self.class.operand(bytes)]
        when :zero_page_x
          @memory[self.class.operand(bytes) + x]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(y)
        affect_zero_flag(y)
      end

      def nop(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied
      end

      def ora(addressing_mode, bytes)
        self.a |= case addressing_mode
        when :absolute
          @memory[self.class.operand(bytes)]
        when :immediate
          self.class.operand(bytes)
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

        push p
      end

      def pla(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.a = pop

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def plp(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p = pop
      end

      def ror(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :accumulator

        shifted = (a << 8) >> 1

        self.a = shifted >> 8
        self.a |= 0x80 if c?

        affect_carry_flag(shifted & 0x80 != 0)
        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def rts(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.pc = pop_word + 1
      end

      def sbc(addressing_mode, bytes)
        value = case addressing_mode
        when :immediate
          self.class.operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        # TODO: verify that SBC is implemented correctly
        borrow = c? ? 0 : 1

        result = a - value - borrow

        self.a = result & 0xff

        affect_carry_flag(result >= 0)
        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def sec(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p |= C_FLAG
      end

      def sei(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p |= I_FLAG
      end

      def sta(addressing_mode, bytes)
        address = case addressing_mode
        when :absolute
          self.class.operand(bytes)
        when :absolute_x
          self.class.operand(bytes) + x
        when :absolute_y
          self.class.operand(bytes) + y
        when :indirect_y
          source = self.class.operand(bytes)
          (@memory[source] | @memory[source + 1] << 8) + y
        when :zero_page
          self.class.operand(bytes)
        when :zero_page_x
          (self.class.operand(bytes) + x) & 0xff
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        @memory[address] = a
      end

      def stx(addressing_mode, bytes)
        address = case addressing_mode
        when :absolute
          self.class.operand(bytes)
        when :zero_page
          self.class.operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        @memory[address] = x
      end

      def sty(addressing_mode, bytes)
        address = case addressing_mode
        when :absolute
          self.class.operand(bytes)
        when :zero_page
          self.class.operand(bytes)
        when :zero_page_x
          (self.class.operand(bytes) + x) & 0xff
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
