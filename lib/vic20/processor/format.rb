# frozen_string_literal: true
module Vic20
  class Processor
    module Format
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

      # TODO: fix this... it's ugly
      def format_instruction(address, instruction)
        addressing_mode = ADDRESSING_MODES[instruction[:addressing_mode]]
        bytes = @memory.get_bytes(address, addressing_mode[:bytes])

        [
          format('%04X', address),
          bytes.map { |byte| format('%02X', byte) }.join(' ').ljust(8, ' '),
          "; #{instruction[:method].upcase} #{format(addressing_mode[:format], @operand)}",
        ].join('  ')
      end
    end
  end
end
