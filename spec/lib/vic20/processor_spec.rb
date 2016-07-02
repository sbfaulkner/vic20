require 'spec_helper'

describe Vic20::Processor do
  subject { described_class.new([]) }

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

    it 'has a 16-bite program counter' do
      expect(subject.pc).to be_a(Vic20::Register)
    end
  end
end
