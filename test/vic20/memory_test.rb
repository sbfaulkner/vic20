# frozen_string_literal: true
require 'test_helper'

class Vic20::MemoryTest < Minitest::Test
  # let(:rom) { subject.get_bytes(address, size) }

  # RSpec::Matchers.define_negated_matcher(:be_present, :be_nil)

  def test_find_unknown_firmware
    assert_nil(Vic20::Memory.find_firmware('unknown'))
  end

  def test_find_basic_firmware
    assert_match(%r{/firmware/basic\..*\.bin\z}, Vic20::Memory.find_firmware('basic'))
  end

  def test_find_character_generator_firmware
    assert_match(%r{/firmware/characters\..*\.bin\z}, Vic20::Memory.find_firmware('characters'))
  end

  def test_find_kernal_firmware
    assert_match(%r{/firmware/kernal\..*\.bin\z}, Vic20::Memory.find_firmware('kernal'))
  end

  def test_new_with_a_block
    memory = Vic20::Memory.new { |m| m.set_byte(0x1200, 0xff) }

    assert_equal(0xff, memory.get_byte(0x1200))
  end

  def test_default_firmware_cold_start_address
    memory = Vic20::Memory.new
    memory.load_firmware

    assert_equal(0xe378, memory.get_word(0xc000))
  end

  def test_load_array
    address = 0x2000
    array = Array(0..255)

    memory = Vic20::Memory.new
    memory.load(array, at: address)

    assert_equal(array, memory.get_bytes(address, 256))
  end

  def test_load_file
    address = 0x2000
    array = Array(0..255)
    path = "/path/to/firmware"

    File.stubs(:read).with(path, mode: 'rb').returns(array.pack('c*'))

    memory = Vic20::Memory.new
    memory.load(path, at: address)

    assert_equal(array, memory.get_bytes(address, 256))
  end

  def test_loads_8K_rom_at_a000
    path = "/path/to/cartridge"
    image = Array.new(8 * 1024, 0xcc)
    image[0] = 0x00
    image[1] = 0x60
    image[-1] = 0xbe
    image[-2] = 0xef
    File.stubs(:read).with(path, mode: 'rb').returns(image.pack('c*'))

    memory = Vic20::Memory.new
    memory.load_roms(path)

    assert_equal(0xbeef, memory.get_word(0xa000 + 8 * 1024 - 2))
  end

  def test_loads_rom_with_leading_address_at_specified_address
    path = "/path/to/cartridge"
    image = Array.new(8 * 1024 + 2, 0xcc)
    image[0] = 0x00
    image[1] = 0x60
    image[-1] = 0xbe
    image[-2] = 0xef
    File.stubs(:read).with(path, mode: 'rb').returns(image.pack('c*'))

    memory = Vic20::Memory.new
    memory.load_roms(path)

    assert_equal(0xbeef, memory.get_word(0x6000 + 8 * 1024 - 2))
  end

  # context '#load_firmware' do
  #   before do
  #     subject.load_firmware
  #   end

  def test_character_generator_rom_loaded
    memory = Vic20::Memory.new
    memory.load_firmware

    rom = memory.get_bytes(0x8000, 4 * 1024)
    firmware = File.read(Vic20::Memory.find_firmware("characters"), mode: "rb").unpack("C*")

    assert_equal(firmware, rom)
  end

  def test_basic_rom_loaded
    memory = Vic20::Memory.new
    memory.load_firmware

    rom = memory.get_bytes(0xc000, 8 * 1024)
    firmware = File.read(Vic20::Memory.find_firmware("basic"), mode: "rb").unpack("C*")

    assert_equal(firmware, rom)
  end

  def test_kernal_rom_loaded
    memory = Vic20::Memory.new
    memory.load_firmware

    rom = memory.get_bytes(0xe000, 8 * 1024)
    firmware = File.read(Vic20::Memory.find_firmware("kernal"), mode: "rb").unpack("C*")

    assert_equal(firmware, rom)
  end

  def test_map_character_rom
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x8000, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_character_rom

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_character_rom_selecting_uppercase_characters
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x8000, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_character_rom(Vic20::Memory::UPPERCASE_CHARACTERS)

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_character_rom_selecting_reverse_characters
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x8400, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_character_rom(Vic20::Memory::REVERSE_CHARACTERS)

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_character_rom_selecting_lowercase_characters
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x8800, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_character_rom(Vic20::Memory::LOWERCASE_CHARACTERS)

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_character_rom_selecting_reverse_lowercase_characters
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x8C00, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_character_rom(Vic20::Memory::REVERSE_CHARACTERS | Vic20::Memory::LOWERCASE_CHARACTERS)

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_colour_memory
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x9600, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_colour_memory

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_colour_memory_with_8k_expansion
    marker = 0xdeadbeef
    memory = Vic20::Memory.new(expansion: 8)
    memory.set_bytes(0x9400, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_colour_memory

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_io_block
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x9000, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_io_block

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_program_memory
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x1000, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_program_memory

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_program_memory_with_8k_expansion
    marker = 0xdeadbeef
    memory = Vic20::Memory.new(expansion: 8)
    memory.set_bytes(0x1200, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_program_memory

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_screen_memory
    marker = 0xdeadbeef
    memory = Vic20::Memory.new
    memory.set_bytes(0x1E00, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_screen_memory

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end

  def test_map_screen_memory_with_8k_expansion
    marker = 0xdeadbeef
    memory = Vic20::Memory.new(expansion: 8)
    memory.set_bytes(0x1000, 4, [marker].pack("N").unpack("C*"))

    mapping = memory.map_screen_memory

    assert_equal(marker, ((mapping[0]<<8|mapping[1])<<8|mapping[2])<<8|mapping[3])
  end
end
