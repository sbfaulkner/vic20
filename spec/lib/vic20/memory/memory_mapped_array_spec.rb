require 'spec_helper'

describe Vic20::Memory::MemoryMappedArray do
  let(:size) { 64 * 1024 }

  subject { described_class.new(size) }

  it 'is initialized to 0' do
    expect(subject[0, size]).to all(eq 0)
  end

  describe '#[]' do
    it 'returns a single item' do
      expect(subject[0]).to eq(0)
    end

    it 'returns an array of items' do
      expect(subject[size - 8, 8]).to eq([0, 0, 0, 0, 0, 0, 0, 0])
    end
  end

  describe '#[]=' do
    it 'replaces a single item' do
      subject[0] = 0xff
      expect(subject[0]).to eq(0xff)
    end

    it 'replaces multiple items' do
      subject[size - 8, 8] = [1, 2, 3, 4, 5, 6, 7, 8]
      expect(subject[size - 8, 8]).to eq([1, 2, 3, 4, 5, 6, 7, 8])
    end
  end
end
