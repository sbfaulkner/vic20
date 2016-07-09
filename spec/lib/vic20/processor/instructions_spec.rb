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
    let(:pc) { 0xfd27 }

    before do
      subject.s = 0xff
      subject.pc = pc
    end

    it 'pushes address-1 to the stack' do
      subject.jsr(:absolute, [0x20, 0x3f, 0xfd])
      expect(word_at(0x01fe)).to eq(pc - 1)
    end

    it 'jumps to the specified address' do
      subject.jsr(:absolute, [0x20, 0x3f, 0xfd])
      expect(subject.pc).to eq(0xfd3f)
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

  def word_at(address)
    memory[address] | memory[address + 1] << 8
  end
end
