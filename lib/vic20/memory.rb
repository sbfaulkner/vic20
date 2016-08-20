module Vic20
  class Memory
    extend Forwardable

    FIRMWARE_DIR = File.expand_path('../../firmware', __dir__)

    def self.find_firmware(name)
      Dir[File.join(FIRMWARE_DIR, "#{name}.*.bin")].first
    end

    DEFAULT_FIRMWARE = {
      0x8000 => find_firmware('characters'),  # 8000-8FFF   32768-36863   4K Character generator ROM
      0xc000 => find_firmware('basic'),       # C000-DFFF   49152-57343   8K Basic ROM
      0xe000 => find_firmware('kernal'),      # E000-FFFF   57344-65535   8K KERNAL ROM
    }.freeze

    def initialize(contents = nil)
      contents ||= DEFAULT_FIRMWARE
      contents = { 0 => contents } if contents.is_a?(String)

      @bytes = Array.new(64 * 1024) { |offset| offset >> 8 }

      contents.each { |address, content| load(address, content) }
    end

    def get_byte(address)
      @bytes[address]
    end

    def get_bytes(address, count)
      @bytes[address, count]
    end

    def get_word(address)
      get_byte(address) | get_byte(address + 1) << 8
    end

    def set_byte(address, byte)
      case address
      when 0x0000..0x03FF # 1K RAM - jump vectors, etc.
        @bytes[address] = byte
      when 0x0400..0x0FFF # 3K Expansion RAM
        # TODO: this is ROM if expansion not present
        @bytes[address] = byte
      when 0x1000..0x1DFF # 3.5K User Basic RAM
        # TODO: relocated if 8K expansion present
        @bytes[address] = byte
      when 0x1E00..0x1FFF # 0.5K Screen RAM
        # TODO: relocated if 8K expansion present
        @bytes[address] = byte
      when 0x2000..0x3FFF # 8K Expansion RAM
        # TODO: this is ROM if expansion not present
        # TODO: relocate other memory if present
        @bytes[address] = byte
      when 0x4000..0x5FFF # 8K Expansion RAM
        # TODO: this is ROM if expansion not present
        @bytes[address] = byte
      when 0x6000..0x7FFF # 8K Expansion RAM
        # TODO: this is ROM if expansion not present
        @bytes[address] = byte
      when 0x8000..0x8FFF # 4K Character Generator ROM
        # read-only
      when 0x9000..0x93FF # 1K I/O block
        # TODO: implement VIA and VIC I/O
        @bytes[address] = byte
      when 0x9400..0x95FF # 0.5K Color RAM (w/ expansion)
        # TODO: relocate to here when expansion in block 1
        @bytes[address] = byte
      when 0x9600..0x97FF # 0.5K Color RAM (normal)
        # TODO: relocate from here when expansion in block 1
        @bytes[address] = byte
      when 0x9800..0x9BFF # 1K I/O block 2
        # TODO: I/O?
        @bytes[address] = byte
      when 0x9800..0x9BFF # 1K I/O block 2
        # TODO: I/O?
        @bytes[address] = byte
      when 0x9C00..0x9FFF # 1K I/O block 3
        # TODO: I/O?
        @bytes[address] = byte
      when 0xA000..0xBFFF # 8K Expansion ROM
        # TODO: cartridge support
        # read-only
      when 0xC000..0xDFFF # 8K Basic ROM
        # read-only
      when 0xE000..0xFFFF # 8K KERNAL ROM
        # read-only
      end
    end

    def set_bytes(address, count, bytes)
      @bytes[address, count] = bytes
    end

    def load(address, content)
      case content
      when Array
        set_bytes(address, content.size, content)
      when String
        load(address, File.read(content, mode: 'rb').bytes)
      else
        raise ArgumentError, "Unsupported content type: #{content.class.name}"
      end
    end
  end
end
