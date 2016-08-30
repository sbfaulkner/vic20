require 'spec_helper'

describe Vic20::Memory do
  let(:rom) { subject.get_bytes(address, size) }

  RSpec::Matchers.define_negated_matcher :be_present, :be_nil

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

    describe '#load' do
      subject { described_class.new }

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

    describe '#get_word' do
      it 'returns the Basic cold start address' do
        expect(subject.get_word(0xC000)).to eq(0xE378)
      end
    end
  end
end
