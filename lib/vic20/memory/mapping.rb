# frozen_string_literal: true
module Vic20
  class Memory
    class Mapping
      def initialize(memory, address)
        @memory = memory
        @address = address
      end

      def [](index)
        @memory.get_byte(@address + index)
      end

      def []=(index, value)
        @memory.set_byte(@address + index, value)
      end
    end
  end
end
