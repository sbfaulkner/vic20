module Vic20
  class Processor
    module Instructions
      module ClassMethods
        def format_operand(addressing_mode, bytes)
          format Vic20::Processor::ADDRESSING_MODES[addressing_mode][:format], extract_operand(bytes)
        end

        def extract_operand(bytes)
          case bytes.size
          when 3
            bytes[1] | bytes[2] << 8
          when 2
            bytes[1]
          end
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

      def cld(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p &= ~D_FLAG
      end

      def cmp(addressing_mode, bytes)
        value = case addressing_mode
        when :absolute_x
          @memory[self.class.extract_operand(bytes) + x]
        # when :immediate
        #   self.class.extract_operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end

        set_flags(a - value, C_FLAG | N_FLAG | Z_FLAG)
      end

      def jsr(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :absolute

        push_word pc - 1
        self.pc = self.class.extract_operand(bytes)
      end

      def lda(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :absolute_x

        self.a = @memory[self.class.extract_operand(bytes) + x]
      end

      def ldx(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :immediate

        self.x = self.class.extract_operand(bytes)
      end

      def sei(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.p |= I_FLAG
      end

      def txs(addressing_mode, _bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :implied

        self.s = x
      end
    end
  end
end
