module Vic20
  class Processor
    module Trace
      def execute(address, method, addressing_mode, bytes)
        STDERR.puts current_state
        STDERR.puts format_instruction(address, method, addressing_mode, bytes)
        super
      end
    end
  end
end
