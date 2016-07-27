module Vic20
  class Processor
    module Trace
      def execute(address, instruction)
        STDERR.puts current_state
        STDERR.puts format_instruction(address, instruction)
        super
      end
    end
  end
end
