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

    it 'raises IndexError when index is beyond array bounds' do
      expect { subject[size] }.to raise_exception(IndexError)
    end

    it 'raises IndexError when length exceeds array bounds' do
      expect { subject[size - 7, 8] }.to raise_exception(IndexError)
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

    it 'raises IndexError when index is beyond array bounds' do
      expect { subject[size] = 0xff }.to raise_exception(IndexError)
    end

    it 'raises IndexError when length exceeds array bounds' do
      expect { subject[size - 7, 8] = [1, 2, 3, 4, 5, 6, 7, 8] }.to raise_exception(IndexError)
    end

    it 'raises TypeError when value is not Array' do
      expect { subject[size - 8, 8] = 0xff }.to raise_exception(TypeError)
    end

    it 'raises ArgumentError when assigned array is too short' do
      expect { subject[size - 8, 8] = [1, 2, 3, 4, 5, 6, 7] }.to raise_exception(ArgumentError)
    end

    it 'raises ArgumentError when assigned array is too long' do
      expect { subject[size - 8, 8] = [1, 2, 3, 4, 5, 6, 7, 8, 9] }.to raise_exception(ArgumentError)
    end
  end
end
