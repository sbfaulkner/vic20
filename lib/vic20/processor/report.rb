module Vic20
  class Processor
    module Report
      def execute(address, method, addressing_mode, bytes)
        super
      rescue
        STDERR.puts current_state
        STDERR.puts format_instruction(address, method, addressing_mode, bytes)
        raise
      end
    end
  end
end
