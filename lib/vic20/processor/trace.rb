# frozen_string_literal: true
module Vic20
  class Processor
    module Trace
      def execute(address, instruction)
        STDERR.print format_instruction(address, instruction)
        super
        STDERR.puts current_state
      end
    end
  end
end
