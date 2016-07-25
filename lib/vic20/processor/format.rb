module Vic20
  class Processor
    module Format
      def format_assembly(method, addressing_mode, bytes)
        "; #{method.upcase} #{format_operand(addressing_mode, bytes)}"
      end

      def format_instruction(address, method, addressing_mode, bytes)
        [
          format('%04X', address),
          bytes.map { |byte| format('%02X', byte) }.join(' ').ljust(8, ' '),
          format_assembly(method, addressing_mode, bytes),
        ].join('  ')
      end

      def format_operand(addressing_mode, bytes)
        format ADDRESSING_MODES[addressing_mode][:format], self.class.operand(bytes)
      end
    end
  end
end
