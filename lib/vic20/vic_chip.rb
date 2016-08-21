module Vic20
  class VicChip
    BLACK = 0
    WHITE = 1
    RED = 2
    CYAN = 3
    PURPLE = 4
    GREEN = 5
    BLUE = 6
    YELLOW = 7
    ORANGE = 8
    LIGHT_ORANGE = 9
    PINK = 10
    LIGHT_CYAN = 11
    LIGHT_PURPLE = 12
    LIGHT_GREEN = 13
    LIGHT_BLUE = 14
    LIGHT_YELLOW = 15

    class Registers
      IO_BLOCK = 0x9000

      def initialize(memory)
        @memory = memory
      end

      def [](index)
        @memory.get_byte(IO_BLOCK + index)
      end

      def []=(index, value)
        @memory.set_byte(IO_BLOCK + index, value)
      end
    end

    def initialize(memory)
      @cr = Registers.new(memory)
    end

    attr_reader :cr
  end
end
