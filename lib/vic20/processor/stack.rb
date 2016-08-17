module Vic20
  class Processor
    module Stack
      STACK_PAGE = 0x0100

      def pop
        self.s = (s + 1) & 0xff
        @memory.get_byte(STACK_PAGE + s)
      end

      def pop_word
        pop | pop << 8
      end

      def push(byte)
        @memory.set_byte(STACK_PAGE + s, byte)
        self.s = (s - 1) & 0xff
      end

      def push_word(word)
        push(word >> 8)
        push(word & 0xff)
      end
    end
  end
end
