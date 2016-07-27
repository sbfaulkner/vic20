module Vic20
  class Processor
    module Format
      def format_instruction(address, instruction)
        bytes = @memory[address, instruction[:bytes]]

        [
          format('%04X', address),
          bytes.map { |byte| format('%02X', byte) }.join(' ').ljust(8, ' '),
          "; #{instruction[:method].upcase} #{format instruction[:format], operand(bytes)}",
        ].join('  ')
      end
    end
  end
end
