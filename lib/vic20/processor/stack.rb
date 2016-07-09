module Vic20
  class Processor
    module Stack
      STACK_PAGE    = 0x0100

      def pop
        self.s += 1
        @memory[STACK_PAGE + s]
      end

      def pop_word
        pop | pop << 8
      end

      def push(byte)
        @memory[STACK_PAGE + s] = byte
        self.s -= 1
      end

      def push_word(word)
        push(word >> 8)
        push(word & 0xff)
      end
    end
  end
end
