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

      def and(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :immediate

        self.a &= self.class.operand(bytes)

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def asl(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :accumulator

        shifted = a << 1

        self.a = shifted & 0xff

        affect_carry_flag(shifted & 0x100 == 0 ? -1 : 1)
        affect_sign_flag(a)
        affect_zero_flag(a)
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
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = a - value

        affect_carry_flag(result)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def cpy(addressing_mode, bytes)
        value = case addressing_mode
        when :immediate
          self.class.operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        result = y - value

        affect_carry_flag(result)
        affect_sign_flag(result)
        affect_zero_flag(result)
      end

      def dex(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.x = (x - 1) & 0xff

        affect_sign_flag(x)
        affect_zero_flag(x)
      end

      def dey(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.y = (y - 1) & 0xff

        affect_sign_flag(y)
        affect_zero_flag(y)
      end

      def eor(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :zero_page_x

        address = (self.class.operand(bytes) + x) & 0xff

        self.a ^= @memory[address]

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

      def jmp(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :absolute

        self.pc = self.class.operand(bytes)
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
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def ldx(addressing_mode, bytes)
        self.x = case addressing_mode
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
        when :immediate
          self.class.operand(bytes)
        when :zero_page
          @memory[self.class.operand(bytes)]
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        affect_sign_flag(y)
        affect_zero_flag(y)
      end

      def ora(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :immediate

        self.a |= self.class.operand(bytes)

        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def ror(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :accumulator

        shifted = (a << 8) >> 1

        self.a = shifted >> 8
        self.a |= 0x80 if c?

        affect_carry_flag(shifted & 0x80 == 0 ? -1 : 1)
        affect_sign_flag(a)
        affect_zero_flag(a)
      end

      def rts(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.pc = pop_word + 1
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
    end
  end
end
