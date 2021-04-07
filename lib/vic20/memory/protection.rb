# frozen_string_literal: true
module Vic20
  class Memory
    module Protection
      private

      def set_rom(address, byte)
        super
        raise "attempt to write #{byte.to_s(16)} to ROM @ $#{address.to_s(16)}"
      end
    end
  end
end
