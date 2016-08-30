require 'spec_helper'

describe Vic20::Processor do
  let(:memory) { Vic20::Memory.new }

  subject { described_class.new(memory) }

  describe '#pop' do
    let(:top)  { 0xff }
    let(:byte) { 0xbf }

    before do
      memory.set_byte(0x100 + top, byte)
      subject.s = top - 1
    end

    it 'increments the stack pointer' do
      subject.pop
      expect(subject.s).to eq(top)
    end

    it 'returns the byte' do
      expect(subject.pop).to eq(byte)
    end

    context 'when stack pointer is at the top' do
      before do
        subject.s = top
      end

      it 'wraps around to the bottom' do
        subject.pop
        expect(subject.s).to eq(0)
      end
    end
  end

  describe '#pop_word' do
    let(:top)  { 0xff }
    let(:word) { 0xbeef }

    before do
      memory.set_byte(0x100 + top, word >> 8)
      memory.set_byte(0x100 + top - 1, word & 0xff)
      subject.s = top - 2
    end

    it 'increments the stack pointer' do
      subject.pop_word
      expect(subject.s).to eq(top)
    end

    it 'returns the word' do
      expect(subject.pop_word).to eq(word)
    end
  end

  describe '#push' do
    let(:top)  { 0xff }
    let(:byte) { 0xbf }

    before do
      subject.s = top
    end

    it 'stores a byte at the offset of the current stack pointer' do
      subject.push byte
      expect(memory.get_byte(0x100 + top)).to eq(byte)
    end

    it 'decrements the stack pointer' do
      subject.push byte
      expect(subject.s).to eq(top - 1)
    end

    context 'when stack pointer is at the bottom' do
      before do
        subject.s = 0
      end

      it 'wraps around to the top' do
        subject.push byte
        expect(subject.s).to eq(top)
      end
    end
  end

  describe '#push_word' do
    let(:top)  { 0xff }
    let(:word) { 0xbeef }

    before do
      subject.s = top
    end

    it 'pushes the most-significant byte first' do
      subject.push_word word
      expect(memory.get_byte(0x100 + top)).to eq(word >> 8)
    end

    it 'pushes the least-significant byte second' do
      subject.push_word word
      expect(memory.get_byte(0x100 + top - 1)).to eq(word & 0xff)
    end

    it 'decrements the stack pointer' do
      subject.push_word word
      expect(subject.s).to eq(top - 2)
    end
  end
end
