module Vic20
  module NMOS6502
    class Register < SimpleDelegator
      attr_accessor :value

      def initialize(value = 0)
        self.value = value

        super(self.value)
      end
    end
  end
end
