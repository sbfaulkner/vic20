# frozen_string_literal: true
module Vic20
  class Processor
    module Halt
      def execute(address, instruction)
        super
        raise Trap, pc if pc == address
      end
    end
  end
end
