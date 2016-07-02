require 'spec_helper'

describe Vic20::Memory do
  describe 'firmware' do
    let(:rom) { subject[address, size] }

    RSpec::Matchers.define_negated_matcher :be_present, :be_nil

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

      it 'is 4K' do
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
end
