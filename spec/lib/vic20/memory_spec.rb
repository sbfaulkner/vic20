# frozen_string_literal: true
require 'spec_helper'

describe Vic20::Memory do
  let(:rom) { subject.get_bytes(address, size) }

  RSpec::Matchers.define_negated_matcher(:be_present, :be_nil)

  describe 'find_firmware' do
    it 'returns nil for an unknown firmware' do
      expect(described_class.find_firmware('unknown')).to be_nil
    end

    it 'returns the full path of the basic firmware' do
      expect(described_class.find_firmware('basic')).to match(%r{/firmware/basic\..*\.bin\z})
    end

    it 'returns the full path of the character generator firmware' do
      expect(described_class.find_firmware('characters')).to match(%r{/firmware/characters\..*\.bin\z})
    end

    it 'returns the full path of the kernal firmware' do
      expect(described_class.find_firmware('kernal')).to match(%r{/firmware/kernal\..*\.bin\z})
    end
  end

  describe '#new with a block' do
    it 'yields the correct class' do
      expect { |b| described_class.new(&b) }.to yield_with_args(described_class)
    end

    it 'returns the same object that was yielded' do
      object = described_class.new { |m| m.set_bytes(0xC000, 1, [0xff]) }
      expect(object.get_byte(0xC000)).to eq(0xff)
    end
  end

  describe '#get_word' do
    context 'with the default firmware loaded' do
      before do
        subject.load_firmware
      end

      it 'returns the Basic cold start address' do
        expect(subject.get_word(0xC000)).to eq(0xE378)
      end
    end
  end

  describe '#load' do
    let(:address) { 0x2000 }
    let(:array) { Array(0..255) }
    let(:path) { '/path/to/firmware' }

    it 'fills the specified location with the array contents when passed an array' do
      subject.load(array, at: address)
      expect(subject.get_bytes(address, 256)).to eq(array)
    end

    it 'fills the specified location with the file contents when passed a file path' do
      allow(File).to receive(:read).with(path, mode: 'rb').and_return(array.pack('c*'))
      subject.load(path, at: address)
      expect(subject.get_bytes(address, 256)).to eq(array)
    end
  end

  describe '#load_roms' do
    let(:image) { Array.new(image_size, 0xcc) }
    let(:path) { '/path/to/cartridge' }

    before do
      image[0] = 0x00
      image[1] = 0x60
      image[image_size - 2] = 0xef
      image[image_size - 1] = 0xbe

      allow(File).to receive(:read).with(path, mode: 'rb').and_return(image.pack('c*'))
    end

    context 'given an 8K image' do
      let(:image_size) { 8 * 1024 }

      it 'loads the rom at $A000' do
        subject.load_roms(path)
        expect(subject.get_word(0xa000 + 8 * 1024 - 2)).to eq(0xbeef)
      end
    end

    context 'given an image with a leading address' do
      let(:image_size) { 8 * 1024 + 2 }

      it 'loads the rom at the specified address' do
        subject.load_roms(path)
        expect(subject.get_word(0x6000 + 8 * 1024 - 2)).to eq(0xbeef)
      end
    end
  end

  context '#load_firmware' do
    before do
      subject.load_firmware
    end

    describe 'Character generator ROM' do
      let(:address) { 0x8000 }
      let(:size) { 4 * 1024 }

      it 'is loaded' do
        expect(rom).to all(be_present)
      end

      it 'is 4K' do
        expect(rom.size).to eq(size)
      end
    end

    describe 'Basic ROM' do
      let(:address) { 0xC000 }
      let(:size) { 8 * 1024 }

      it 'is loaded' do
        expect(rom).to all(be_present)
      end

      it 'is 8K' do
        expect(rom.size).to eq(size)
      end
    end

    describe 'KERNAL ROM' do
      let(:address) { 0xE000 }
      let(:size) { 8 * 1024 }

      it 'is loaded' do
        expect(rom).to all(be_present)
      end

      it 'is 4K' do
        expect(rom.size).to eq(size)
      end
    end
  end

  describe '#map_character_rom' do
    let(:mapping) { subject.map_character_rom }

    it 'maps to 0x8000' do
      subject.set_bytes(0x8000, 1, [0xff])
      expect(mapping[0]).to eq(0xff)
    end

    context 'when selecting uppercase characters' do
      let(:mapping) { subject.map_character_rom(Vic20::Memory::UPPERCASE_CHARACTERS) }

      it 'maps to 0x8000' do
        subject.set_bytes(0x8000, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end

    context 'when selecting reversed characters' do
      let(:mapping) { subject.map_character_rom(Vic20::Memory::REVERSE_CHARACTERS) }

      it 'maps to 0x8400' do
        subject.set_bytes(0x8400, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end

    context 'when selecting lowercase characters' do
      let(:mapping) { subject.map_character_rom(Vic20::Memory::LOWERCASE_CHARACTERS) }

      it 'maps to 0x8800' do
        subject.set_bytes(0x8800, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end

    context 'when selecting reversed, lowercase characters' do
      let(:mapping) do
        subject.map_character_rom(Vic20::Memory::REVERSE_CHARACTERS | Vic20::Memory::LOWERCASE_CHARACTERS)
      end

      it 'maps to 0x8C00' do
        subject.set_bytes(0x8C00, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end
  end

  describe '#map_colour_memory' do
    let(:mapping) { subject.map_colour_memory }

    context 'when unexpanded' do
      it 'maps to 0x9600' do
        subject.set_bytes(0x9600, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end

    context 'when expanded' do
      subject { described_class.new(expansion: 8) }

      it 'maps to 0x9400' do
        subject.set_bytes(0x9400, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end
  end

  describe '#map_io_block' do
    let(:mapping) { subject.map_io_block }

    it 'maps to 0x9000' do
      subject.set_bytes(0x9000, 1, [0xff])
      expect(mapping[0]).to eq(0xff)
    end
  end

  describe '#map_program_memory' do
    let(:mapping) { subject.map_program_memory }

    context 'when unexpanded' do
      it 'maps to 0x1000' do
        subject.set_bytes(0x1000, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end

    context 'when expanded' do
      subject { described_class.new(expansion: 8) }

      it 'maps to 0x1200' do
        subject.set_bytes(0x1200, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end
  end

  describe '#map_screen_memory' do
    let(:mapping) { subject.map_screen_memory }

    context 'when unexpanded' do
      it 'maps to 0x1E00' do
        subject.set_bytes(0x1E00, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end

    context 'when expanded' do
      subject { described_class.new(expansion: 8) }

      it 'maps to 0x1000' do
        subject.set_bytes(0x1000, 1, [0xff])
        expect(mapping[0]).to eq(0xff)
      end
    end
  end
end
