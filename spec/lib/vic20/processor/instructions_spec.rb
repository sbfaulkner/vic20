require 'spec_helper'

describe Vic20::Processor do
  let(:signature_address) { 0xfd4d }
  let(:signature) { ['A'.ord, '0'.ord, 0xc3, 0xc2, 0xcd] }
  let(:memory) { [] }

  subject { described_class.new(memory) }

  before do
    memory[signature_address, 5] = signature
  end

  describe '#bne' do
    let(:pc) { 0xfd49 }

    before do
      subject.pc = pc
    end

    # FD47  D0 03     ; BNE $03
    it 'branches when zero flag is clear' do
      subject.p = 0x00
      subject.bne(:relative, [0xd0, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'does not branch when zero flag is set' do
      subject.p = 0xff
      subject.bne(:relative, [0xd0, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#cld' do
    before do
      subject.p = 0xff
    end

    it 'clears the binary-coded decimal flag' do
      subject.cld(:implied, [0xd8])
      expect(subject.d?).to be_falsey
    end
  end

  describe '#cmp' do
    context 'with absolute,x addressing mode' do
      let(:address) { 0xa003 }

      before do
        subject.a = signature[4]
        subject.x = 0x05
        memory[address + 5] = value
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:absolute_x, [0xdd, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end
    end
  end

  describe '#lda' do
    it 'should affect the N & Z flags'

    context 'with absolute,x addressing mode' do
      let(:address) { signature_address - 1 }
      let(:value) { signature[4] }

      before do
        subject.a = 0x00
        subject.x = 0x05
      end

      it 'sets the accumulator to the value' do
        subject.lda(:absolute_x, [0xbd, lsb(address), msb(address)])
        expect(subject.a).to eq(value)
      end
    end
  end

  describe '#ldx' do
    it 'should affect the N & Z flags'

    context 'with immediate addressing mode' do
      let(:value) { 0xff }

      before do
        subject.x = 0x00
      end

      it 'sets the x index register to the value' do
        subject.ldx(:immediate, [0xa2, value])
        expect(subject.x).to eq(value)
      end
    end
  end

  describe '#jsr' do
    let(:top) { 0x1ff }
    let(:pc) { 0xfd27 }
    let(:destination) { 0xfd3f }

    before do
      subject.s = 0xff
      subject.pc = pc
    end

    it 'pushes address-1 to the stack' do
      subject.jsr(:absolute, [0x20, lsb(destination), msb(destination)])
      expect(word_at(top - 1)).to eq(pc - 1)
    end

    it 'jumps to the specified address' do
      subject.jsr(:absolute, [0x20, lsb(destination), msb(destination)])
      expect(subject.pc).to eq(destination)
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
    let(:value) { 0xff }

    before do
      subject.s = 0x00
      subject.x = value
    end

    it 'transfers the x-index register to the stack pointer' do
      subject.txs(:implied, [0x9a])
      expect(subject.s).to eq(value)
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
