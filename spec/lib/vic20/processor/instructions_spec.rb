require 'spec_helper'

describe Vic20::Processor do
  let(:memory) { [] }
  subject { described_class.new(memory) }

  describe '#cld' do
    before do
      subject.p = 0xff
    end

    it 'clears the binary-coded decimal flag' do
      subject.cld(:implied, [0xd8])
      expect(subject.d?).to be_falsey
    end
  end

  describe '#ldx' do
    let(:value) { 0xff }

    before do
      subject.x = 0x00
    end

    it 'should affect the N & Z flags'

    context 'with immediate addressing mode' do
      it 'sets the x index register to the value' do
        subject.ldx(:immediate, [0xa2, value])
        expect(subject.x).to eq(value)
      end
    end
  end

  describe '#jsr' do
    let(:top) { 0x1ff }
    let(:pc) { 0xfd27 }
    let(:address) { 0xfd3f }

    before do
      subject.s = 0xff
      subject.pc = pc
    end

    it 'pushes address-1 to the stack' do
      subject.jsr(:absolute, [0x20, lsb(address), msb(address)])
      expect(word_at(top - 1)).to eq(pc - 1)
    end

    it 'jumps to the specified address' do
      subject.jsr(:absolute, [0x20, lsb(address), msb(address)])
      expect(subject.pc).to eq(address)
    end
  end

  describe '#sei' do
    before do
      subject.p = 0x00
    end

    it 'sets the interrupt flag' do
      subject.sei(:implied, [0x78])
      expect(subject.i?).to be_truthy
    end
  end

  describe '#txs' do
    before do
      subject.s = 0x00
      subject.x = 0xbf
    end

    it 'transfers the x-index register to the stack pointer' do
      subject.txs(:implied, [0x9a])
      expect(subject.s).to eq(subject.x)
    end
  end

  private

  def lsb(word)
    word & 0xff
  end

  def msb(word)
    word >> 8
  end

  def word_at(address)
    memory[address] | memory[address + 1] << 8
  end
end
