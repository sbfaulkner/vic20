require_relative 'memory/mapping'
require_relative 'memory/protection'

module Vic20
  class Memory
    extend Forwardable

    FIRMWARE_DIR = File.expand_path('../../firmware', __dir__)

    BASIC_ROM_ADDRESS               = 0xC000
    CHARACTER_ROM_ADDRESS           = 0x8000
    DEFAULT_COLOR_MEMORY_ADDRESS    = 0x9600
    DEFAULT_PROGRAM_MEMORY_ADDRESS  = 0x1000
    DEFAULT_SCREEN_MEMORY_ADDRESS   = 0x1E00
    IO_BLOCK_ADDRESS                = 0x9000
    EXPANDED_COLOR_MEMORY_ADDRESS   = 0x9400
    EXPANDED_PROGRAM_MEMORY_ADDRESS = 0x1200
    EXPANDED_SCREEN_MEMORY_ADDRESS  = 0x1000
    KERNAL_ROM_ADDRESS              = 0xE000

    UPPERCASE_CHARACTERS = 0x0000
    REVERSE_CHARACTERS   = 0x0400
    LOWERCASE_CHARACTERS = 0x0800

    def self.find_firmware(name)
      Dir[File.join(FIRMWARE_DIR, "#{name}.*.bin")].first
    end

    DEFAULT_FIRMWARE = {
      CHARACTER_ROM_ADDRESS => find_firmware('characters'), # 8000-8FFF   32768-36863   4K Character generator ROM
      BASIC_ROM_ADDRESS => find_firmware('basic'),          # C000-DFFF   49152-57343   8K Basic ROM
      KERNAL_ROM_ADDRESS => find_firmware('kernal'),        # E000-FFFF   57344-65535   8K KERNAL ROM
    }.freeze

    def initialize(expansion: 0)
      @bytes = Array.new(64 * 1024, 0)

      @expansion = expansion

      @pages = build_pages
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
      @pages[address >> 8].call(address, byte)
    end

    def set_bytes(address, count, bytes)
      @bytes[address, count] = bytes
    end

    def load(content, at: 0)
      case content
      when Array
        set_bytes(at, content.size, content)
      when String
        load(File.read(content, mode: 'rb').bytes, at: at)
      else
        raise ArgumentError, "Unsupported content type: #{content.class.name}"
      end
    end

    def load_firmware
      DEFAULT_FIRMWARE.each do |address, content|
        load(content, at: address)
      end
    end

    def map_character_rom(characters = UPPERCASE_CHARACTERS)
      Mapping.new(self, CHARACTER_ROM_ADDRESS | characters)
    end

    def map_colour_memory
      Mapping.new(self, @expansion > 3 ? EXPANDED_COLOR_MEMORY_ADDRESS : DEFAULT_COLOR_MEMORY_ADDRESS)
    end

    def map_io_block
      Mapping.new(self, IO_BLOCK_ADDRESS)
    end

    def map_program_memory
      Mapping.new(self, @expansion > 3 ? EXPANDED_PROGRAM_MEMORY_ADDRESS : DEFAULT_PROGRAM_MEMORY_ADDRESS)
    end

    def map_screen_memory
      Mapping.new(self, @expansion > 3 ? EXPANDED_SCREEN_MEMORY_ADDRESS : DEFAULT_SCREEN_MEMORY_ADDRESS)
    end

    private

    def set_color(address, byte)
      @bytes[address] = byte
    end

    def set_ram(address, byte)
      @bytes[address] = byte
    end

    def set_rom(address, byte)
    end

    def set_screen(address, byte)
      @bytes[address] = byte
    end

    def build_pages
      Array.new(256) do |page|
        method case page
        when 0x00..0x03 # 1K RAM - jump vectors, etc.
          :set_ram
        when 0x04..0x0F # 3K Expansion RAM
          (@expansion & 3 == 3) ? :set_ram : :set_rom
        when 0x10..0x11
          # 0.5K User Basic RAM - without 8K expansion
          # 0.5K Screen RAM - with 8K expansion
          @expansion > 3 ? :set_screen : :set_ram
        when 0x12..0x1D
          # 3K User Basic RAM - without 8K expansion
          # start of User Basic RAM - with 8K expansion
          :set_ram
        when 0x1E..0x1F
          # 0.5K Screen RAM - without 8K expansion
          @expansion > 3 ? :set_ram : :set_screen
        when 0x20..0x3F # 8K Expansion RAM
          @expansion > 3 ? :set_ram : :set_rom
        when 0x40..0x5F # 8K Expansion RAM
          @expansion > 11 ? :set_ram : :set_rom
        when 0x60..0x7F # 8K Expansion RAM
          @expansion > 19 ? :set_ram : :set_rom
        when 0x80..0x8F # 4K Character Generator ROM
          # read-only
          :set_rom
        when 0x90..0x93 # 1K I/O block
          # TODO: implement VIA and VIC I/O
          :set_ram
        when 0x94..0x95 # 0.5K Color RAM (w/ expansion)
          @expansion > 3 ? :set_color : :set_ram
        when 0x96..0x97 # 0.5K Color RAM (normal)
          @expansion > 3 ? :set_ram : :set_color
        when 0x98..0x9B # 1K I/O block 2
          # TODO: I/O?
          :set_ram
        when 0x9C..0x9F # 1K I/O block 3
          # TODO: I/O?
          :set_ram
        when 0xA0..0xBF # 8K Expansion ROM
          # TODO: cartridge support
          :set_rom
        when 0xC0..0xDF # 8K Basic ROM
          :set_rom
        when 0xE0..0xFF # 8K KERNAL ROM
          :set_rom
        end
      end
    end
  end
end
