module Vic20
  class Memory
    module Screendump
      private

      def set_screen(address, byte)
        super.tap do
          address = @expansion < 8 ? 0x1e00 : 0x1000

          @bytes[address, 23 * 22].each_slice(22) do |bytes|
            STDERR.printf "%04X  %s\n", address, bytes.map { |b| 0xe200 + b }.pack('U*')
            address += 16
          end

          STDERR.puts
        end
      end
    end
  end
end
