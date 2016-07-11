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

      def bne(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :relative

        self.pc += self.class.relative_operand(bytes) unless z?
      end

      def cld(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~D_FLAG
      end

      def cmp(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute_x
          @memory[self.class.operand(bytes) + x]
        # when :immediate
        #   self.class.operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        set_flags(a - value, C_FLAG | N_FLAG | Z_FLAG)
      end

      def inx(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.x = (x + 1) & 0xff

        set_flags(x, N_FLAG | Z_FLAG)
      end

      def jsr(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :absolute

        push_word pc - 1
        self.pc = self.class.operand(bytes)
      end

      def lda(addressing_mode, bytes)
        self.a = case addressing_mode
        when :absolute_x
          @memory[self.class.operand(bytes) + x]
        when :immediate
          self.class.operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        set_flags(a, N_FLAG | Z_FLAG)
      end

      def ldx(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :immediate

        self.x = self.class.operand(bytes)

        set_flags(x, N_FLAG | Z_FLAG)
      end

      def ldy(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :immediate

        self.y = self.class.operand(bytes)

        set_flags(y, N_FLAG | Z_FLAG)
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
        when :absolute_x
          self.class.operand(bytes) + x
        when :zero_page_x
          (self.class.operand(bytes) + x) & 0xff
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        @memory[address] = a
      end

      def tax(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.x = a

        set_flags(x, N_FLAG | Z_FLAG)
      end

      def txs(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.s = x
      end
    end
  end
end
