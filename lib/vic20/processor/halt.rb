module Vic20
  class Processor
    module Halt
      def execute(address, method, addressing_mode, bytes)
        super
        raise Trap(pc) if pc == address
      end
    end
  end
end
