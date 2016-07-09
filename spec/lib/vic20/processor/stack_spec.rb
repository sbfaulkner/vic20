require 'spec_helper'

describe Vic20::Processor do
  let(:memory) { [] }
  subject { described_class.new(memory) }

  describe '#pop' do
    let(:top)  { 0xff }
    let(:byte) { 0xbf }

    before do
      memory[0x100 + top] = byte
      subject.s = top - 1
    end

    it 'increments the stack pointer' do
      subject.pop
      expect(subject.s).to eq(top)
    end

    it 'returns the byte' do
      expect(subject.pop).to eq(byte)
    end
  end

  describe '#pop_word' do
    let(:top)  { 0xff }
    let(:word) { 0xbeef }

    before do
      memory[0x100 + top] = word >> 8
      memory[0x100 + top - 1] = word & 0xff
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
      expect(memory[0x100 + top]).to eq(byte)
    end

    it 'decrements the stack pointer' do
      subject.push byte
      expect(subject.s).to eq(top - 1)
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
      expect(memory[0x100 + top]).to eq(word >> 8)
    end

    it 'pushes the least-significant byte second' do
      subject.push_word word
      expect(memory[0x100 + top - 1]).to eq(word & 0xff)
    end

    it 'decrements the stack pointer' do
      subject.push_word word
      expect(subject.s).to eq(top - 2)
    end
  end
end