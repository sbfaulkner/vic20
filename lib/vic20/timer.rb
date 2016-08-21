module Vic20
  class Timer
    class Register
      def initialize
        @value = 0
      end

      attr_accessor :value

      def [](bit)
        @value[bit]
      end

      def []=(bit, value)
        @value &= ~(1 << bit)
        @value |= (value << bit)
        value
      end
    end

    def initialize(memory)
      @memory = memory

      @pa = Register.new
      @pb = Register.new
    end

    attr_reader :pa, :pb
  end
end
