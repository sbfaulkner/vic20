module Vic20
  class Processor
    module Breakpoints
      def breakpoints
        @breakpoints ||= []
      end

      def execute(address, instruction)
        super
        raise Trap, pc if breakpoints.include?(pc)
      end
    end
  end
end
