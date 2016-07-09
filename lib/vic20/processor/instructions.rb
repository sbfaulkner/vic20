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

      def jsr(addressing_mode, bytes)
        raise UnsupportedAddressingMode, addressing_mode unless addressing_mode == :absolute

        raise "JSR #{self.class.extract_operand(bytes)}"
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
