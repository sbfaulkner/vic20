# frozen_string_literal: true
module Vic20
  class Processor
    module Format
      ADDRESSING_MODES = {
        absolute: { bytes: 3, format: '$%04x' },
        absolute_x: { bytes: 3, format: '$%04x,x' },
        absolute_y: { bytes: 3, format: '$%04x,y' },
        accumulator: { bytes: 1, format: 'a' },
        immediate: { bytes: 2, format: '#$%02x' },
        implied: { bytes: 1, format: '' },
        indirect: { bytes: 3, format: '($%02x)' },
        indirect_x: { bytes: 2, format: '($%02x,x)' },
        indirect_y: { bytes: 2, format: '($%02x),y' },
        relative: { bytes: 2, format: '$%02x' },
        zero_page: { bytes: 2, format: '$%02x' },
        zero_page_x: { bytes: 2, format: '$%02x,x' },
        zero_page_y: { bytes: 2, format: '$%02x,y' },
      }.freeze

      # TODO: fix this... it's ugly
      def format_instruction(address, instruction)
        addressing_mode = ADDRESSING_MODES[instruction[:addressing_mode]]
        bytes = @memory.get_bytes(address, addressing_mode[:bytes])

        [
          format('%04x : ', address),
          bytes.map { |byte| format('%02x', byte) }.join.ljust(6, ' '),
          " ; #{instruction[:method].downcase} #{format(addressing_mode[:format], @operand)}",
        ].join.ljust(34, ' ')


      end
    end
  end
end
