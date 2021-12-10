# frozen_string_literal: true
require 'ipc/memory_mapped_array'

require 'vic20/memory/mapping'
require 'vic20/memory/protection'

require 'forwardable'

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

    NMI_VECTOR    = 0xFFFA
    RESET_VECTOR  = 0xFFFC
    IRQ_VECTOR    = 0xFFFE

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
      @bytes = IPC::MemoryMappedArray.new(64 * 1024)

      @expansion = expansion

      @pages = build_pages

      yield self if block_given?
    end

    def get_byte(address)
      @bytes[address].tap { |b| memdebug("get_byte", address, b) }
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

    def load_roms(*paths)
      paths.each do |path|
        content = File.read(path, mode: 'rb').bytes

        if content.size % 1024 == 2
          address = content.shift + content.shift << 8
          load(content, at: address)
        else
          load(content, at: 0xa000)
        end
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

    def irq_vector
      get_word(IRQ_VECTOR)
    end

    def nmi_vector
      get_word(NMI_VECTOR)
    end

    def reset_vector
      get_word(RESET_VECTOR)
    end

    private

    VIAREGISTERS = [
      "ORB/IRB",
      "ORA/IRA",
      "DDRB",
      "DDRA",
      "T1C-L",
      "T1C-H",
      "T1L-L",
      "T1L-H",
      "T2C-L",
      "T2C-H",
      "SR",
      "ACR",
      "PCR",
      "IFR",
      "IER",
      "ORA/IRA"
    ]

    def self.viadecodebyte(b)
      b.chr.inspect
    end

    def self.viadecodeddr(b)
      format("%08b", b).tr("01", "IO")
    end

    # clock rate is 1.02 MHz (NTSC)
    # VIA2 timer 1 set to 17033 ($4289)
    # 1.02MHz / 17033 => (approx) 60Hz

    VIAACRT1 = [
      "timed interrupt each time
      T1 is loaded - PB7 disabled",
      "continuous interrupts - PB7 disabled",
      "timed interrupt each time
      T1 is loaded - PB7 one-shot",
      "continuous interrupts - PB7 square wave output",
    ]

    VIAACRT2 = [
      "timed interrupt",
      "countdown with pulses on PB6",
    ]

    VIAACRSR = [
      "disabled",
      "shift in under control of T2",
      "shift in under control of PHI2",
      "shift in under control of external clock",
      "shift out free-running at T2 rate",
      "shift out under control of T2",
      "shift out under control of PHI2",
      "shift out under control of external clock",
    ]

    VIAACRLATCH = [
      "disable",
      "enable",
    ]

    def self.viadecodeacr(b)
      t1 = VIAACRT1[(b & 0b11000000) >> 6]
      t2 = VIAACRT2[(b & 0b00100000) >> 5]
      sr = VIAACRSR[(b & 0b00011100) >> 2]
      pb = VIAACRLATCH[(b & 0b00000010) >> 1]
      pa = VIAACRLATCH[(b & 0b00000010) >> 1]

      "T1 #{t1}, T2 #{t2}, SR #{sr}, PB latch #{pb}, PA latch #{pa}"
    end

    VIAPCRCONTROL = [
      "Input-negative active edge",
      "Independent interrupt input-negative edge",
      "Input-positive active edge",
      "Independent interrupt input-positive edge",
      "Handshake output",
      "Pulse output",
      "Low output",
      "High output ",
    ]

    VIAPCRINTERRUPTCONTROL = [
      "Negative active edge",
      "Positive active edge",
    ]

    def self.viadecodepcr(b)
      cb2 = VIAPCRCONTROL[(b & 0b11100000) >> 5]
      cb1 = VIAPCRINTERRUPTCONTROL[(b & 0b00010000) >> 4]
      ca2 = VIAPCRCONTROL[(b & 0b00001110) >> 1]
      ca1 = VIAPCRINTERRUPTCONTROL[b & 0b00000001]

      "CB2 #{cb2}, CB1 #{cb1}, CA2 #{ca2}, CA1 #{ca1}"
    end

    VIAIFRBITS = [
      "CA2",
      "CA1",
      "SR",
      "CB2",
      "CB1",
      "T2",
      "T1",
      "IRQ",
    ]

    def self.viadecodeifr(b)
      bits = VIAIFRBITS.each_with_index.map do |name, bit|
        name unless b[bit].zero?
      end
      bits.compact.reverse.join(",")
    end

    VIAIERBITS = [
      "CA2",
      "CA1",
      "SR",
      "CB2",
      "CB1",
      "T2",
      "T1",
    ]

    def self.viadecodeier(b)
      op = (b & 0x80) == 0 ? "disable" : "enable"
      bits = VIAIERBITS.each_with_index.map do |name, bit|
        name unless b[bit].zero?
      end
      "Interrupt #{op} (#{bits.compact.reverse.join(",")})"
    end

    VIADECODE = [
      method(:viadecodebyte),
      method(:viadecodebyte),
      method(:viadecodeddr),
      method(:viadecodeddr),
      method(:viadecodebyte),
      method(:viadecodebyte),
      method(:viadecodebyte),
      method(:viadecodebyte),
      method(:viadecodebyte),
      method(:viadecodebyte),
      method(:viadecodebyte),
      method(:viadecodeacr),
      method(:viadecodepcr),
      method(:viadecodeifr),
      method(:viadecodeier),
      method(:viadecodebyte),
    ]

    def viaregister(address)
      "VIA##{(address & 0xff) >> 4} #{}"
    end

    def memdebug(label, address, b)
      return viadebug(label, address, b) if via?(address)
      warn "[#{label}]\t$#{format("%04x: $%02x", address, b)}"
    end

    def viadebug(label, address, b)
      via = (address & 0xff) >> 4
      register = address&0x0f

      warn "[#{label}]\t$#{format("%04x: $%02x", address, b)} ; VIA##{via} #{VIAREGISTERS[register]}\t#{VIADECODE[register].call(b)}"
    end

    def via?(address)
      # [0x9110, 0x9120].include?(address & 0xfff0)
      (address & 0xfff0) == 0x9120
    end

    def set_color(address, byte)
      @bytes[address] = byte
    end

    def set_ram(address, byte)
      memdebug("set_ram", address, byte)
      @bytes[address] = byte
    end

    def set_rom(address, byte)
    end

    def set_screen(address, byte)
      @bytes[address] = byte
    end

    def build_pages
      Array.new(256) { |page| method(page_method_name(page)) }
    end

    def page_method_name(page)
      case page
      when 0x00..0x03 # 1K RAM - jump vectors, etc.
        :set_ram
      when 0x04..0x0F # 3K Expansion RAM
        @expansion & 3 == 3 ? :set_ram : :set_rom
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
