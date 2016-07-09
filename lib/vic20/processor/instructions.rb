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

      def jsr(addressing_mode, bytes)
        case addressing_mode
        when :absolute
          raise "JSR #{self.class.extract_operand(bytes)}"
        else
          raise UnsupportedAddressingMode, addressing_mode
        end
      end

      def ldx(addressing_mode, bytes)
        case addressing_mode
        when :immediate
          self.x = self.class.extract_operand(bytes)
        else
          raise UnsupportedAddressingMode, addressing_mode
        end
      end
    end
  end
end
