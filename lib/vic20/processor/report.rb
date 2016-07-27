module Vic20
  class Processor
    module Report
      def execute(address, instruction)
        super
      rescue
        STDERR.puts current_state
        STDERR.puts format_instruction(address, instruction)
        raise
      end
    end
  end
end
