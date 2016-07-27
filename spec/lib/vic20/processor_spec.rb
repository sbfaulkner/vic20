require 'spec_helper'

describe Vic20::Processor do
  let(:memory) { [] }
  subject { described_class.new(memory) }

  describe 'registers' do
    it 'has an 8-bit accumulator' do
      expect(subject.a).to be_a(Integer)
    end

    it 'has an 8-bit x index register' do
      expect(subject.x).to be_a(Integer)
    end

    it 'has an 8-bit y index register' do
      expect(subject.y).to be_a(Integer)
    end

    it 'has 7 processor status flag bits' do
      expect(subject.p).to be_a(Integer)
    end

    describe 'processor status flag bits' do
      context 'when set to 0' do
        it 'has bit 5 set' do
          subject.p = 0
          expect(subject.p[5]).to eq(1)
        end
      end

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
      expect(subject.s).to be_a(Integer)
    end

    it 'has a 16-bit program counter' do
      expect(subject.pc).to be_a(Integer)
    end
  end

  context 'with a program in memory' do
    let(:program) do
      [
        [0x0600, [0x20, 0x09, 0x06]], # JSR $0609
        [0x0603, [0x20, 0x0c, 0x06]], # JSR $060c
        [0x0606, [0x20, 0x12, 0x06]], # JSR $0612
        [0x0609, [0xa2, 0x00]],       # LDX #$00
        [0x060b, [0x60]],             # RTS
        [0x060c, [0xe8]],             # INX
        [0x060d, [0xe0, 0x05]],       # CPX #$05
        [0x060f, [0xd0, 0xfb]],       # BNE $060c
        [0x0611, [0x60]],             # RTS
        [0x0612, [0x00]],             # BRK
      ]
    end

    before do
      program.each do |a, b|
        memory[a, b.size] = b
      end
      subject.pc = 0x0600
    end

    describe '#each' do
      it 'yields the instructions' do
        # TODO: this is very coupled to implementation
        expect { |b| subject.each(&b) }.to yield_successive_args(*program.map { |a, b| [a, described_class.instructions[b.first]] })
      end

      it 'advances the program counter' do
        subject.each {}
        expect(subject.pc).to eq(0x0613)
      end
    end

    describe '#run' do
      it 'runs the program' do
        program.each do |_address, bytes|
          instruction = described_class.instructions[bytes.first]
          expect(subject).to receive(instruction[:method]).with(instruction[:addressing_mode], bytes)
        end

        subject.run
      end
    end
  end

  context 'with the 6502 functional test suite', slow: true do
    class FunctionalTestProcessor < Vic20::Processor
      Vic20::Processor.prepend Vic20::Processor::Halt
      Vic20::Processor.prepend Vic20::Processor::Report
    end

    let(:firmware) { File.expand_path('../../../firmware/6502_functional_test.bin', __dir__) }
    let(:memory) { Vic20::Memory.new(firmware) }

    subject { FunctionalTestProcessor.new(memory) }

    before do
      subject.reset(0x0400)
    end

    it 'runs the test successfully' do
      expect { subject.run }.to raise_exception(Vic20::Processor::Trap, /Execution halted @ \$3399/)
    end
  end
end
