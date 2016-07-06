require 'spec_helper'

describe Vic20::Processor do
  let(:memory) { [] }
  subject { described_class.new(memory) }

  describe 'registers' do
    it 'has an 8-bit accumulator' do
      expect(subject.a).to be_a(Vic20::Register)
    end

    it 'has an 8-bit x index register' do
      expect(subject.x).to be_a(Vic20::Register)
    end

    it 'has an 8-bit y index register' do
      expect(subject.y).to be_a(Vic20::Register)
    end

    it 'has 7 processor status flag bits' do
      expect(subject.p).to be_a(Vic20::Register)
    end

    describe 'processor status flag bits' do
      it 'has a carry flag' do
        expect { subject.c? }.not_to raise_exception
      end

      it 'has a zero flag' do
        expect { subject.z? }.not_to raise_exception
      end

      it 'has an interrupt flag' do
        expect { subject.i? }.not_to raise_exception
      end

      it 'has a binary-coded decimal flag' do
        expect { subject.d? }.not_to raise_exception
      end

      it 'has a breakpoint flag' do
        expect { subject.b? }.not_to raise_exception
      end

      it 'has an overflow flag' do
        expect { subject.v? }.not_to raise_exception
      end

      it 'has a sign flag' do
        expect { subject.n? }.not_to raise_exception
      end
    end

    it 'has an 8-bit stack pointer' do
      expect(subject.s).to be_a(Vic20::Register)
    end

    it 'has a 16-bit program counter' do
      expect(subject.pc).to be_a(Vic20::Register)
    end
  end

  describe '#each' do
    before do
      memory[0x0600, 3] = [0x20, 0x09, 0x06]  # JSR $0609
      memory[0x0603, 3] = [0x20, 0x0c, 0x06]  # JSR $060c
      memory[0x0606, 3] = [0x20, 0x12, 0x06]  # JSR $0612
      memory[0x0609, 2] = [0xa2, 0x00]        # LDX #$00
      memory[0x060b, 1] = [0x60]              # RTS
      memory[0x060c, 1] = [0xe8]              # INX
      memory[0x060d, 2] = [0xe0, 0x05]        # CPX #$05
      memory[0x060f, 2] = [0xd0, 0xfb]        # BNE $060c
      memory[0x0611, 1] = [0x60]              # RTS
      memory[0x0612, 1] = [0x00]              # BRK
    end

    it 'yields the instructions' do
      subject.pc = 0x0600
      expect { |b| subject.each(&b) }.to yield_successive_args(
        [:jsr, :absolute, 0x09, 0x06],
        [:jsr, :absolute, 12, 6],
        [:jsr, :absolute, 18, 6],
        [:ldx, :immediate, 0],
        [:rts, :implied],
        [:inx, :implied],
        [:cpx, :immediate, 5],
        [:bne, :relative, 251],
        [:rts, :implied],
        [:brk, :implied]
      )
    end

    it 'advances the program counter' do
      subject.pc = 0x0600
      subject.each {}
      expect(subject.pc).to eq(0x0613)
    end
  end
end
