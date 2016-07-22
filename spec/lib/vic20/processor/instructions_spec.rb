require 'spec_helper'

describe Vic20::Processor do
  # TODO: refactor signature out into tests that need it
  let(:signature_address) { 0xfd4d }
  let(:signature) { ['A'.ord, '0'.ord, 0xc3, 0xc2, 0xcd] }
  let(:memory) { [] }

  subject { described_class.new(memory) }

  before do
    memory[signature_address, 5] = signature
  end

  describe '#adc' do
    let(:a) { 0x40 }
    let(:value) { 0x0f }

    before do
      subject.a = a
      subject.p = 0xff
    end

    context 'with immediate addressing mode' do
      it 'adds the specified value to the accumulator' do
        subject.adc(:immediate, [0x69, value])
        expect(subject.a).to eq(a + value)
      end

      it 'clears the carry flag' do
        subject.adc(:immediate, [0x69, value])
        expect(subject.c?).to be_falsey
      end

      it 'clears the sign flag' do
        subject.adc(:immediate, [0x69, value])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.adc(:immediate, [0x69, value])
        expect(subject.z?).to be_falsey
      end

      context 'when the result is > 255' do
        let(:a) { 0xfe }

        it 'sets the carry flag' do
          subject.adc(:immediate, [0x69, value])
          expect(subject.c?).to be_truthy
        end
      end

      context 'when the result has bit 7 set' do
        let(:a) { 0x7e }

        it 'sets the sign flag' do
          subject.adc(:immediate, [0x69, value])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is 0' do
        let(:a) { 0xf1 }

        it 'sets the zero flag' do
          subject.adc(:immediate, [0x69, value])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x3f }

      before do
        memory[address] = value
      end

      it 'adds the addressed value to the accumulator' do
        subject.adc(:zero_page, [0x65, address])
        expect(subject.a).to eq(a + value)
      end

      it 'clears the carry flag' do
        subject.adc(:zero_page, [0x65, address])
        expect(subject.c?).to be_falsey
      end

      it 'clears the sign flag' do
        subject.adc(:zero_page, [0x65, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.adc(:zero_page, [0x65, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the result is > 255' do
        let(:a) { 0xfe }

        it 'sets the carry flag' do
          subject.adc(:zero_page, [0x65, address])
          expect(subject.c?).to be_truthy
        end
      end

      context 'when the result has bit 7 set' do
        let(:a) { 0x7e }

        it 'sets the sign flag' do
          subject.adc(:zero_page, [0x65, address])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is 0' do
        let(:a) { 0xf1 }

        it 'sets the zero flag' do
          subject.adc(:zero_page, [0x65, address])
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#and' do
    context 'with immediate addressing mode' do
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        subject.a = mask
      end

      it 'ands the accumulator with the provided value' do
        subject.and(:immediate, [0x29, value])
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and(:immediate, [0x29, value])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and(:immediate, [0x29, value])
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and(:immediate, [0x29, value])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and(:immediate, [0x29, value])
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#asl' do
    context 'with absolute addressing mode' do
      let(:address) { 0x3e44 }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits left one position' do
        subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
        expect(memory[address]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl(:absolute, [0x0e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:address) { 0x3e44 }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory[address + offset] = value
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
        expect(memory[address + offset]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl(:absolute_x, [0x1e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits left one position' do
        subject.asl(:accumulator, [0x0a])
        expect(subject.a).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl(:accumulator, [0x0a])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl(:accumulator, [0x0a])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl(:accumulator, [0x0a])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl(:accumulator, [0x0a])
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl(:accumulator, [0x0a])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl(:accumulator, [0x0a])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl(:accumulator, [0x0a])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x3e }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits left one position' do
        subject.asl(:zero_page, [0x06, address])
        expect(memory[address]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl(:zero_page, [0x06, address])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl(:zero_page, [0x06, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl(:zero_page, [0x06, address])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl(:zero_page, [0x06, address])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl(:zero_page, [0x06, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl(:zero_page, [0x06, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl(:zero_page, [0x06, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0x3e }
      let(:offset) { 5 }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[(address + offset) & 0xff] = value
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.asl(:zero_page_x, [0x16, address])
        expect(memory[address + offset]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl(:zero_page_x, [0x16, address])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl(:zero_page_x, [0x16, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl(:zero_page_x, [0x16, address])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl(:zero_page_x, [0x16, address])
          expect(memory[address + offset]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl(:zero_page_x, [0x16, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl(:zero_page_x, [0x16, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl(:zero_page_x, [0x16, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.asl(:zero_page_x, [0x16, address])
          expect(memory[address + offset - 0x100]).to eq(value << 1 & 0xff)
        end
      end
    end
  end

  describe '#bcc' do
    let(:pc) { 0xfdde }

    before do
      subject.pc = pc
    end

    it 'branches when carry flag is clear' do
      subject.p = 0x00
      subject.bcc(:relative, [0x90, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when carry flag is clear' do
      subject.p = 0x00
      subject.bcc(:relative, [0x90, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when carry flag is set' do
      subject.p = 0xff
      subject.bcc(:relative, [0x90, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#bcs' do
    let(:pc) { 0xfdde }

    before do
      subject.pc = pc
    end

    it 'branches when carry flag is set' do
      subject.p = 0xff
      subject.bcs(:relative, [0xb0, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when carry flag is set' do
      subject.p = 0xff
      subject.bcs(:relative, [0xb0, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when carry flag is clear' do
      subject.p = 0x00
      subject.bcs(:relative, [0xb0, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#beq' do
    let(:pc) { 0xfdba }

    before do
      subject.pc = pc
    end

    it 'branches when zero flag is set' do
      subject.p = 0xff
      subject.beq(:relative, [0xf0, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when zero flag is set' do
      subject.p = 0xff
      subject.beq(:relative, [0xf0, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when zero flag is clear' do
      subject.p = 0x00
      subject.beq(:relative, [0xf0, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#bit' do
    let(:mask) { 0x01 }
    let(:value) { 0xc5 }

    before do
      subject.a = mask
      memory[address] = value
    end

    context 'with absolute addressing mode' do
      let(:address) { 0xa9a9 }

      it 'sets the sign flag' do
        subject.bit(:absolute, [0x2c, address])
        expect(subject.n?).to be_truthy
      end

      it 'sets the overflow flag' do
        subject.bit(:absolute, [0x2c, address])
        expect(subject.v?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.bit(:absolute, [0x2c, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the 6th and 7th bits of the value are clear' do
        let(:value) { 0x05 }

        it 'clears the sign flag' do
          subject.bit(:absolute, [0x2c, address])
          expect(subject.n?).to be_falsey
        end

        it 'clears the overflow flag' do
          subject.bit(:absolute, [0x2c, address])
          expect(subject.v?).to be_falsey
        end
      end

      context 'when the result is zero' do
        let(:mask) { ~value & 0xff }

        it 'sets the zero flag' do
          subject.bit(:absolute, [0x2c, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xa9 }

      it 'sets the sign flag' do
        subject.bit(:zero_page, [0x24, address])
        expect(subject.n?).to be_truthy
      end

      it 'sets the overflow flag' do
        subject.bit(:zero_page, [0x24, address])
        expect(subject.v?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.bit(:zero_page, [0x24, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the 6th and 7th bits of the value are clear' do
        let(:value) { 0x05 }

        it 'clears the sign flag' do
          subject.bit(:zero_page, [0x24, address])
          expect(subject.n?).to be_falsey
        end

        it 'clears the overflow flag' do
          subject.bit(:zero_page, [0x24, address])
          expect(subject.v?).to be_falsey
        end
      end

      context 'when the result is zero' do
        let(:mask) { ~value & 0xff }

        it 'sets the zero flag' do
          subject.bit(:zero_page, [0x24, address])
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#bmi' do
    let(:pc) { 0xfd49 }

    before do
      subject.pc = pc
    end

    it 'branches when sign flag is set' do
      subject.p = 0xff
      subject.bmi(:relative, [0x30, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when sign flag is set' do
      subject.p = 0xff
      subject.bmi(:relative, [0x30, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when sign flag is clear' do
      subject.p = 0x00
      subject.bmi(:relative, [0x30, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#bne' do
    let(:pc) { 0xfd49 }

    before do
      subject.pc = pc
    end

    it 'branches when zero flag is clear' do
      subject.p = 0x00
      subject.bne(:relative, [0xd0, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when zero flag is clear' do
      subject.p = 0x00
      subject.bne(:relative, [0xd0, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when zero flag is set' do
      subject.p = 0xff
      subject.bne(:relative, [0xd0, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#bpl' do
    let(:pc) { 0xfd49 }

    before do
      subject.pc = pc
    end

    it 'branches when sign flag is clear' do
      subject.p = 0x00
      subject.bpl(:relative, [0x10, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when sign flag is clear' do
      subject.p = 0x00
      subject.bpl(:relative, [0x10, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when sign flag is set' do
      subject.p = 0xff
      subject.bpl(:relative, [0x10, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#brk' do
    let(:pc) { 0x0982 }
    let(:p) { 0x02 }
    let(:top) { 0x1ff }
    let(:irq) { 0xdead }

    before do
      memory[0xfffe, 2] = [lsb(irq), msb(irq)]
      subject.s = top & 0xff
      subject.pc = pc
      subject.p = p
    end

    it 'pushes 3 bytes onto the stack' do
      expect { subject.brk(:implied, [0x00]) }.to change { subject.s }.by(-3)
    end

    it 'pushes the program counter + 1 onto the stack' do
      subject.brk(:implied, [0x00])
      expect(word_at(top - 1)).to eq(pc + 1)
    end

    it 'pushes the processor status onto the stack' do
      subject.brk(:implied, [0x00])
      expect(memory[top - 2] & 0b11001111).to eq(p & 0b11001111)
    end

    it 'pushes the processor status with the breakpoint flag set onto the stack' do
      subject.brk(:implied, [0x00])
      expect(memory[top - 2] & Vic20::Processor::B_FLAG).to eq(Vic20::Processor::B_FLAG)
    end

    it 'loads the IRQ vector at $fffe into the program counter' do
      subject.brk(:implied, [0x00])
      expect(subject.pc).to eq(irq)
    end

    it 'sets the breakpoint flag' do
      subject.brk(:implied, [0x00])
      expect(subject.b?).to be_truthy
    end

    it 'sets the interrupt flag' do
      subject.brk(:implied, [0x00])
      expect(subject.i?).to be_truthy
    end
  end

  describe '#bvc' do
    let(:pc) { 0xfd49 }

    before do
      subject.pc = pc
    end

    it 'branches when overflow flag is clear' do
      subject.p = 0x00
      subject.bvc(:relative, [0x50, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when overflow flag is clear' do
      subject.p = 0x00
      subject.bvc(:relative, [0x50, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when overflow flag is set' do
      subject.p = 0xff
      subject.bvc(:relative, [0x50, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#bvs' do
    let(:pc) { 0xfd49 }

    before do
      subject.pc = pc
    end

    it 'branches when overflow flag is set' do
      subject.p = 0xff
      subject.bvs(:relative, [0x70, 0x03])
      expect(subject.pc).to eq(pc + 3)
    end

    it 'branches backwards when overflow flag is set' do
      subject.p = 0xff
      subject.bvs(:relative, [0x70, 0xfd])
      expect(subject.pc).to eq(pc - 3)
    end

    it 'does not branch when overflow flag is clear' do
      subject.p = 0x00
      subject.bvs(:relative, [0x70, 0x03])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#clc' do
    before do
      subject.p = 0xff
    end

    it 'clears the carry flag' do
      subject.clc(:implied, [0x18])
      expect(subject.c?).to be_falsey
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

  describe '#cli' do
    before do
      subject.p = 0xff
    end

    it 'clears the interrupt flag' do
      subject.cli(:implied, [0x58])
      expect(subject.i?).to be_falsey
    end
  end

  describe '#clv' do
    before do
      subject.p = 0xff
    end

    it 'clears the overflow flag' do
      subject.clv(:implied, [0xb8])
      expect(subject.v?).to be_falsey
    end
  end

  describe '#cmp' do
    context 'with absolute addressing mode' do
      let(:address) { 0xa008 }

      before do
        subject.a = signature[4]
        memory[address] = value
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:absolute, [0xcd, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end
    end

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

    context 'with absolute,y addressing mode' do
      let(:address) { 0xa003 }

      before do
        subject.a = signature[4]
        subject.y = 0x05
        memory[address + 5] = value
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:absolute_y, [0xd9, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with immediate addressing mode' do
      before do
        subject.a = 0xc5
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:immediate, [0xc9, value])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with indirect,x addressing mode' do
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }

      before do
        subject.a = 0x80
        memory[indirect_address] = value
        memory[(address + offset) & 0xff, 2] = [lsb(indirect_address), msb(indirect_address)]
        subject.x = offset
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.z?).to be_truthy
        end

        context 'when the offset exceeds page bounds' do
          let(:offset) { 0xff }

          it 'wraps around' do
            subject.cmp(:indirect_x, [0xc1, address])
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:indirect_x, [0xc1, address])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }

      before do
        subject.a = 0x80
        memory[indirect_address + offset] = value
        memory[address, 2] = [lsb(indirect_address), msb(indirect_address)]
        subject.y = offset
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:indirect_y, [0xd1, address])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x34 }

      before do
        subject.a = 0xc5
        memory[address] = value
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:zero_page, [0xc5, address])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0x34 }
      let(:offset) { 5 }

      before do
        subject.a = 0xc5
        subject.x = offset
        memory[(address + offset) & 0xff] = value
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }
        let(:value) { subject.a }

        it 'wraps around' do
          subject.cmp(:zero_page_x, [0xd5, address])
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#cpx' do
    context 'with absolute addressing mode' do
      let(:address) { 0xa008 }

      before do
        subject.x = signature[4]
        memory[address] = value
      end

      context 'when the x-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the x-index register is equal to the addressed value' do
        let(:value) { subject.x }

        it 'sets the carry flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the x-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx(:absolute, [0xec, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with immediate addressing mode' do
      before do
        subject.x = 0xc5
      end

      context 'when the x-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { subject.x }

        it 'sets the carry flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx(:immediate, [0xe0, value])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x34 }

      before do
        subject.x = 0xc5
        memory[address] = value
      end

      context 'when the x-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the x-index register is equal to the addressed value' do
        let(:value) { subject.x }

        it 'sets the carry flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the x-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx(:zero_page, [0xe4, address])
          expect(subject.z?).to be_falsey
        end
      end
    end
  end

  describe '#cpy' do
    context 'with absolute addressing mode' do
      let(:address) { 0xa008 }

      before do
        subject.y = signature[4]
        memory[address] = value
      end

      context 'when the y-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { subject.y }

        it 'sets the carry flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy(:absolute, [0xcc, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with immediate addressing mode' do
      before do
        subject.y = 0xc5
      end

      context 'when the y-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { subject.y }

        it 'sets the carry flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy(:immediate, [0xc0, value])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x34 }

      before do
        subject.y = 0xc5
        memory[address] = value
      end

      context 'when the y-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { subject.y }

        it 'sets the carry flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy(:zero_page, [0xc4, address])
          expect(subject.z?).to be_falsey
        end
      end
    end
  end

  describe '#dec' do
    let(:value) { 1 }

    context 'with absolute addressing mode' do
      let(:address) { 0xa11a }

      before do
        memory[address] = value
      end

      it 'decrements the value' do
        subject.dec(:absolute, [0xce, lsb(address), msb(address)])
        expect(memory[address]).to eq(value - 1)
      end

      it 'clears the sign flag' do
        subject.dec(:absolute, [0xce, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.dec(:absolute, [0xce, lsb(address), msb(address)])
        expect(subject.z?).to be_truthy
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'decrements the value' do
          subject.dec(:absolute, [0xce, lsb(address), msb(address)])
          expect(memory[address]).to eq(value - 1)
        end

        it 'sets the sign flag' do
          subject.dec(:absolute, [0xce, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec(:absolute, [0xce, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0' do
        let(:value) { 0 }

        it 'rolls over to 0xff' do
          subject.dec(:absolute, [0xce, lsb(address), msb(address)])
          expect(memory[address]).to eq(0xff)
        end

        it 'sets the sign flag' do
          subject.dec(:absolute, [0xce, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec(:absolute, [0xce, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x1a }

      before do
        memory[address] = value
      end

      it 'decrements the value' do
        subject.dec(:zero_page, [0xc6, address])
        expect(memory[address]).to eq(value - 1)
      end

      it 'clears the sign flag' do
        subject.dec(:zero_page, [0xc6, address])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.dec(:zero_page, [0xc6, address])
        expect(subject.z?).to be_truthy
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'decrements the value' do
          subject.dec(:zero_page, [0xc6, address])
          expect(memory[address]).to eq(value - 1)
        end

        it 'sets the sign flag' do
          subject.dec(:zero_page, [0xc6, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec(:zero_page, [0xc6, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0' do
        let(:value) { 0 }

        it 'rolls over to 0xff' do
          subject.dec(:zero_page, [0xc6, address])
          expect(memory[address]).to eq(0xff)
        end

        it 'sets the sign flag' do
          subject.dec(:zero_page, [0xc6, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec(:zero_page, [0xc6, address])
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0x1a }
      let(:offset) { 0xa1 }

      before do
        memory[(address + offset) & 0xff] = value
        subject.x = offset
      end

      it 'decrements the value' do
        subject.dec(:zero_page_x, [0xd6, address])
        expect(memory[(address + offset) & 0xff]).to eq(value - 1)
      end

      it 'clears the sign flag' do
        subject.dec(:zero_page_x, [0xd6, address])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.dec(:zero_page_x, [0xd6, address])
        expect(subject.z?).to be_truthy
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'decrements the value' do
          subject.dec(:zero_page_x, [0xd6, address])
          expect(memory[(address + offset) & 0xff]).to eq(value - 1)
        end

        it 'sets the sign flag' do
          subject.dec(:zero_page_x, [0xd6, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec(:zero_page_x, [0xd6, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0' do
        let(:value) { 0 }

        it 'rolls over to 0xff' do
          subject.dec(:zero_page_x, [0xd6, address])
          expect(memory[(address + offset) & 0xff]).to eq(0xff)
        end

        it 'sets the sign flag' do
          subject.dec(:zero_page_x, [0xd6, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec(:zero_page_x, [0xd6, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.dec(:zero_page_x, [0xd6, address])
          expect(memory[(address + offset) & 0xff]).to eq(value - 1)
        end
      end
    end
  end

  describe '#dex' do
    let(:x) { 1 }

    before do
      subject.x = x
    end

    it 'decrements the x-index register' do
      subject.dex(:implied, [0xca])
      expect(subject.x).to eq(x - 1)
    end

    it 'clears the sign flag' do
      subject.dex(:implied, [0xca])
      expect(subject.n?).to be_falsey
    end

    it 'sets the zero flag' do
      subject.dex(:implied, [0xca])
      expect(subject.z?).to be_truthy
    end

    context 'when the initial value is 0xff' do
      let(:x) { 0xff }

      it 'decrements the x-index register' do
        subject.dex(:implied, [0xca])
        expect(subject.x).to eq(x - 1)
      end

      it 'sets the sign flag' do
        subject.dex(:implied, [0xca])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dex(:implied, [0xca])
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0' do
      let(:x) { 0 }

      it 'rolls over to 0xff' do
        subject.dex(:implied, [0xca])
        expect(subject.x).to eq(0xff)
      end

      it 'sets the sign flag' do
        subject.dex(:implied, [0xca])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dex(:implied, [0xca])
        expect(subject.z?).to be_falsey
      end
    end
  end

  describe '#dey' do
    let(:y) { 1 }

    before do
      subject.y = y
    end

    it 'decrements the y-index register' do
      subject.dey(:implied, [0x88])
      expect(subject.y).to eq(y - 1)
    end

    it 'clears the sign flag' do
      subject.dey(:implied, [0x88])
      expect(subject.n?).to be_falsey
    end

    it 'sets the zero flag' do
      subject.dey(:implied, [0x88])
      expect(subject.z?).to be_truthy
    end

    context 'when the initial value is 0xff' do
      let(:y) { 0xff }

      it 'decrements the y-index register' do
        subject.dey(:implied, [0x88])
        expect(subject.y).to eq(y - 1)
      end

      it 'sets the sign flag' do
        subject.dey(:implied, [0x88])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dey(:implied, [0x88])
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0' do
      let(:y) { 0 }

      it 'rolls over to 0xff' do
        subject.dey(:implied, [0x88])
        expect(subject.y).to eq(0xff)
      end

      it 'sets the sign flag' do
        subject.dey(:implied, [0x88])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dey(:implied, [0x88])
        expect(subject.z?).to be_falsey
      end
    end
  end

  describe '#eor' do
    context 'with immediate addressing mode' do
      let(:mask) { 0x3c }
      let(:value) { 0x0f }

      before do
        subject.a = mask
      end

      it 'xors the accumulator with the value' do
        subject.eor(:immediate, [0x49, value])
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor(:immediate, [0x49, value])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor(:immediate, [0x49, value])
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor(:immediate, [0x49, value])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor(:immediate, [0x49, value])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0xc1 }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }
      let(:offset) { 0x0e }

      before do
        memory[(address + offset) & 0xff] = value
        subject.a = mask
        subject.x = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor(:zero_page_x, [0x55, address])
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor(:zero_page_x, [0x55, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor(:zero_page_x, [0x55, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor(:zero_page_x, [0x55, address])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor(:zero_page_x, [0x55, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.eor(:zero_page_x, [0x55, address])
          expect(subject.a).to eq(value ^ mask)
        end
      end
    end
  end

  describe '#inc' do
    let(:value) { 0 }

    context 'with absolute addressing mode' do
      let(:address) { 0xc105 }

      before do
        memory[address] = value
      end

      it 'increments the value at the specified address' do
        subject.inc(:absolute, [0xee, lsb(address), msb(address)])
        expect(memory[address]).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc(:absolute, [0xee, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc(:absolute, [0xee, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc(:absolute, [0xee, lsb(address), msb(address)])
          expect(memory[address]).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc(:absolute, [0xee, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc(:absolute, [0xee, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc(:absolute, [0xee, lsb(address), msb(address)])
          expect(memory[address]).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc(:absolute, [0xee, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc(:absolute, [0xee, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:address) { 0xc1d5 }
      let(:offset) { 0xbb }

      before do
        memory[address + offset] = value
        subject.x = offset
      end

      it 'increments the value at the specified address' do
        subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
        expect(memory[address + offset]).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc(:absolute_x, [0xfe, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xc1 }

      before do
        memory[address] = value
      end

      it 'increments the value at the specified address' do
        subject.inc(:zero_page, [0xe6, address])
        expect(memory[address]).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc(:zero_page, [0xe6, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc(:zero_page, [0xe6, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc(:zero_page, [0xe6, address])
          expect(memory[address]).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc(:zero_page, [0xe6, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc(:zero_page, [0xe6, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc(:zero_page, [0xe6, address])
          expect(memory[address]).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc(:zero_page, [0xe6, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc(:zero_page, [0xe6, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0xc1 }
      let(:offset) { 0x18 }

      before do
        memory[(address + offset) & 0xff] = value
        subject.x = offset
      end

      it 'increments the value at the specified address' do
        subject.inc(:zero_page_x, [0xf6, address])
        expect(memory[(address + offset) & 0xff]).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc(:zero_page_x, [0xf6, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc(:zero_page_x, [0xf6, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc(:zero_page_x, [0xf6, address])
          expect(memory[(address + offset) & 0xff]).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc(:zero_page_x, [0xf6, address])
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc(:zero_page_x, [0xf6, address])
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc(:zero_page_x, [0xf6, address])
          expect(memory[(address + offset) & 0xff]).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc(:zero_page_x, [0xf6, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc(:zero_page_x, [0xf6, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.inc(:zero_page_x, [0xf6, address])
          expect(memory[(address + offset) & 0xff]).to eq(value + 1)
        end
      end
    end
  end

  describe '#inx' do
    let(:x) { 0 }

    before do
      subject.x = x
    end

    it 'increments the x-index register' do
      subject.inx(:implied, [0xe8])
      expect(subject.x).to eq(x + 1)
    end

    it 'clears the sign flag' do
      subject.inx(:implied, [0xe8])
      expect(subject.n?).to be_falsey
    end

    it 'clears the zero flag' do
      subject.inx(:implied, [0xe8])
      expect(subject.z?).to be_falsey
    end

    context 'when the initial value is 0x7f' do
      let(:x) { 0x7f }

      it 'increments the x-index register' do
        subject.inx(:implied, [0xe8])
        expect(subject.x).to eq(x + 1)
      end

      it 'sets the sign flag' do
        subject.inx(:implied, [0xe8])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.inx(:implied, [0xe8])
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0xff' do
      let(:x) { 0xff }

      it 'rolls over to zero' do
        subject.inx(:implied, [0xe8])
        expect(subject.x).to eq(0)
      end

      it 'clears the sign flag' do
        subject.inx(:implied, [0xe8])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.inx(:implied, [0xe8])
        expect(subject.z?).to be_truthy
      end
    end
  end

  describe '#iny' do
    let(:y) { 0 }

    before do
      subject.y = y
    end

    it 'increments the y-index register' do
      subject.iny(:implied, [0xc8])
      expect(subject.y).to eq(y + 1)
    end

    it 'clears the sign flag' do
      subject.iny(:implied, [0xc8])
      expect(subject.n?).to be_falsey
    end

    it 'clears the zero flag' do
      subject.iny(:implied, [0xc8])
      expect(subject.z?).to be_falsey
    end

    context 'when the initial value is 0x7f' do
      let(:y) { 0x7f }

      it 'increments the x-index register' do
        subject.iny(:implied, [0xc8])
        expect(subject.y).to eq(y + 1)
      end

      it 'sets the sign flag' do
        subject.iny(:implied, [0xc8])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.iny(:implied, [0xc8])
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0xff' do
      let(:y) { 0xff }

      it 'rolls over to zero' do
        subject.iny(:implied, [0xc8])
        expect(subject.y).to eq(0)
      end

      it 'clears the sign flag' do
        subject.iny(:implied, [0xc8])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.iny(:implied, [0xc8])
        expect(subject.z?).to be_truthy
      end
    end
  end

  describe '#jmp' do
    let(:pc) { 0xfdd2 }
    let(:destination) { 0xfe7b }

    before do
      subject.pc = pc
    end

    context 'with absolute addressing mode' do
      it 'transfers program control to the new address' do
        subject.jmp(:absolute, [0x4c, lsb(destination), msb(destination)])
        expect(subject.pc).to eq(destination)
      end
    end

    context 'with indirect addressing mode' do
      let(:address) { 0xc000 }

      before do
        memory[address, 2] = [lsb(destination), msb(destination)]
      end

      it 'transfers program control to the new address' do
        subject.jmp(:indirect, [0x6c, lsb(address), msb(address)])
        expect(subject.pc).to eq(destination)
      end
    end
  end

  describe '#jsr' do
    let(:top) { 0x1ff }
    let(:pc) { 0xfd27 }
    let(:destination) { 0xfd3f }

    before do
      subject.s = top & 0xff
      subject.pc = pc
    end

    it 'pushes a word onto the stack' do
      expect { subject.jsr(:absolute, [0x20, lsb(destination), msb(destination)]) }.to change { subject.s }.by(-2)
    end

    it 'pushes address-1 to the stack' do
      subject.jsr(:absolute, [0x20, lsb(destination), msb(destination)])
      expect(word_at(top - 1)).to eq(pc - 1)
    end

    it 'transfers program control to the new address' do
      subject.jsr(:absolute, [0x20, lsb(destination), msb(destination)])
      expect(subject.pc).to eq(destination)
    end
  end

  describe '#lda' do
    context 'with absolute addressing mode' do
      let(:address) { signature_address + 4 }
      let(:value) { signature[4] }

      before do
        subject.a = 0x00
      end

      it 'sets the accumulator to the value' do
        subject.lda(:absolute, [0xad, lsb(address), msb(address)])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:absolute, [0xad, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:absolute, [0xad, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        before do
          memory[address] = 0
        end

        it 'clears the sign flag' do
          subject.lda(:absolute, [0xad, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:absolute, [0xad, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:address) { signature_address - 1 }
      let(:value) { signature[4] }

      before do
        subject.a = 0x00
        subject.x = 5
      end

      it 'sets the accumulator to the value' do
        subject.lda(:absolute_x, [0xbd, lsb(address), msb(address)])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:absolute_x, [0xbd, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:absolute_x, [0xbd, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        before do
          memory[address + 5] = 0
        end

        it 'clears the sign flag' do
          subject.lda(:absolute_x, [0xbd, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:absolute_x, [0xbd, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:address) { signature_address - 1 }
      let(:value) { signature[4] }

      before do
        subject.a = 0x00
        subject.y = 5
      end

      it 'sets the accumulator to the value' do
        subject.lda(:absolute_y, [0xb9, lsb(address), msb(address)])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:absolute_y, [0xb9, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:absolute_y, [0xb9, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        before do
          memory[address + 5] = 0
        end

        it 'clears the sign flag' do
          subject.lda(:absolute_y, [0xb9, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:absolute_y, [0xb9, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing_mode' do
      let(:value) { 0xff }

      before do
        subject.a = 0x00
      end

      it 'sets the accumulator to the value' do
        subject.lda(:immediate, [0xa9, value])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:immediate, [0xa9, value])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:immediate, [0xa9, value])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda(:immediate, [0xa9, value])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:immediate, [0xa9, value])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with indirect,x addressing mode' do
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0xff }

      before do
        memory[indirect_address] = value
        memory[(address + offset) & 0xff, 2] = [lsb(indirect_address), msb(indirect_address)]
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.lda(:indirect_x, [0xa1, address])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:indirect_x, [0xa1, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:indirect_x, [0xa1, address])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda(:indirect_x, [0xa1, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:indirect_x, [0xa1, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.lda(:indirect_x, [0xa1, address])
          expect(subject.a).to eq(value)
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0xff }

      before do
        memory[indirect_address + offset] = value
        memory[address, 2] = [lsb(indirect_address), msb(indirect_address)]
        subject.y = offset
      end

      it 'sets the accumulator to the value' do
        subject.lda(:indirect_y, [0xb1, address])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:indirect_y, [0xb1, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:indirect_y, [0xb1, address])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda(:indirect_y, [0xb1, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:indirect_y, [0xb1, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x9 }
      let(:value) { 0xff }

      before do
        memory[address] = value
        subject.a = 0x00
      end

      it 'sets the accumulator to the value' do
        subject.lda(:zero_page, [0xa5, address])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:zero_page, [0xa5, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:zero_page, [0xa5, address])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda(:zero_page, [0xa5, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:zero_page, [0xa5, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0x09 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory[(address + offset) & 0xff] = value
        subject.a = 0x00
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.lda(:zero_page_x, [0xb5, address])
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda(:zero_page_x, [0xb5, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda(:zero_page_x, [0xb5, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda(:zero_page_x, [0xb5, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda(:zero_page_x, [0xb5, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.lda(:zero_page_x, [0xb5, address])
          expect(subject.a).to eq(value)
        end
      end
    end
  end

  describe '#ldx' do
    context 'with absolute addressing mode' do
      let(:address) { 0xc15a }
      let(:value) { 0xff }

      before do
        memory[address] = value
        subject.x = 0x00
      end

      it 'sets the x index register to the value' do
        subject.ldx(:absolute, [0xae, lsb(address), msb(address)])
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx(:absolute, [0xae, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx(:absolute, [0xae, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx(:absolute, [0xae, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx(:absolute, [0xae, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:address) { 0x09a0 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory[address + offset] = value
        subject.x = 0x00
        subject.y = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldx(:absolute_y, [0xbe, lsb(address), msb(address)])
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx(:absolute_y, [0xbe, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx(:absolute_y, [0xbe, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx(:absolute_y, [0xbe, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx(:absolute_y, [0xbe, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:value) { 0xff }

      before do
        subject.x = 0x00
      end

      it 'sets the x index register to the value' do
        subject.ldx(:immediate, [0xa2, value])
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx(:immediate, [0xa2, value])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx(:immediate, [0xa2, value])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx(:immediate, [0xa2, value])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx(:immediate, [0xa2, value])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xc1 }
      let(:value) { 0xff }

      before do
        memory[address] = value
        subject.x = 0x00
      end

      it 'sets the x index register to the value' do
        subject.ldx(:zero_page, [0xa6, address])
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx(:zero_page, [0xa6, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx(:zero_page, [0xa6, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx(:zero_page, [0xa6, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx(:zero_page, [0xa6, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,y addressing mode' do
      let(:address) { 0x09 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory[(address + offset) & 0xff] = value
        subject.x = 0x00
        subject.y = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldx(:zero_page_y, [0xb6, address])
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx(:zero_page_y, [0xb6, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx(:zero_page_y, [0xb6, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx(:zero_page_y, [0xb6, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx(:zero_page_y, [0xb6, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.ldx(:zero_page_y, [0xb6, address])
          expect(subject.x).to eq(value)
        end
      end
    end
  end

  describe '#ldy' do
    context 'with absolute addressing mode' do
      let(:address) { 0xc2a8 }
      let(:value) { 0xff }

      before do
        memory[address] = value
        subject.y = 0x00
      end

      it 'sets the y index register to the value' do
        subject.ldy(:absolute, [0xa4, lsb(address), msb(address)])
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy(:absolute, [0xa4, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy(:absolute, [0xa4, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy(:absolute, [0xa4, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy(:absolute, [0xa4, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:address) { 0xa309 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory[address + offset] = value
        subject.y = 0x00
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldy(:absolute_x, [0xbc, lsb(address), msb(address)])
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy(:absolute_x, [0xbc, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy(:absolute_x, [0xbc, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy(:absolute_x, [0xbc, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy(:absolute_x, [0xbc, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:value) { 0xff }

      before do
        subject.y = 0x00
      end

      it 'sets the y index register to the value' do
        subject.ldy(:immediate, [0xa0, value])
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy(:immediate, [0xa0, value])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy(:immediate, [0xa0, value])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy(:immediate, [0xa0, value])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy(:immediate, [0xa0, value])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xc2 }
      let(:value) { 0xff }

      before do
        memory[address] = value
        subject.y = 0x00
      end

      it 'sets the y index register to the value' do
        subject.ldy(:zero_page, [0xa4, address])
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy(:zero_page, [0xa4, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy(:zero_page, [0xa4, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy(:zero_page, [0xa4, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy(:zero_page, [0xa4, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0x09 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory[(address + offset) & 0xff] = value
        subject.y = 0x00
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldy(:zero_page_x, [0xb4, address])
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy(:zero_page_x, [0xb4, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy(:zero_page_x, [0xb4, address])
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy(:zero_page_x, [0xb4, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy(:zero_page_x, [0xb4, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.ldy(:zero_page_x, [0xb4, address])
          expect(subject.y).to eq(value)
        end
      end
    end
  end

  describe '#lsr' do
    context 'with absolute addressing mode' do
      let(:address) { 0xe444 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits right one position' do
        subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
        expect(memory[address]).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr(:absolute, [0x4e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:address) { 0xe444 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory[address + offset] = value
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
        expect(memory[address + offset]).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr(:absolute_x, [0x5e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:value) { 0b01110101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits right one position' do
        subject.lsr(:accumulator, [0x4a])
        expect(subject.a).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr(:accumulator, [0x4a])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr(:accumulator, [0x4a])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr(:accumulator, [0x4a])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr(:accumulator, [0x4a])
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr(:accumulator, [0x4a])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr(:accumulator, [0x4a])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr(:accumulator, [0x4a])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xe4 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits right one position' do
        subject.lsr(:zero_page, [0x4a, address])
        expect(memory[address]).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr(:zero_page, [0x4a, address])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr(:zero_page, [0x4a, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr(:zero_page, [0x4a, address])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr(:zero_page, [0x4a, address])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr(:zero_page, [0x4a, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr(:zero_page, [0x4a, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr(:zero_page, [0x4a, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0xe4 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }
      let(:offset) { 5 }

      before do
        subject.p = flags
        memory[(address + offset) & 0xff] = value
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.lsr(:zero_page_x, [0x56, address])
        expect(memory[(address + offset) & 0xff]).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr(:zero_page_x, [0x56, address])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr(:zero_page_x, [0x56, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr(:zero_page_x, [0x56, address])
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr(:zero_page_x, [0x56, address])
          expect(memory[(address + offset) & 0xff]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr(:zero_page_x, [0x56, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr(:zero_page_x, [0x56, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr(:zero_page_x, [0x56, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.lsr(:zero_page_x, [0x56, address])
          expect(memory[(address + offset) & 0xff]).to eq(value >> 1 & 0xff)
        end
      end
    end
  end

  describe '#nop' do
    it 'is successful' do
      expect { subject.nop(:implied, [0xea]) }.not_to raise_exception
    end
  end

  describe '#ora' do
    context 'with absolute addressing mode' do
      let(:address) { 0x0288 }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory[address] = value
        subject.a = mask
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora(:absolute, [0x0d, lsb(address), msb(address)])
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora(:absolute, [0x0d, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora(:absolute, [0x0d, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora(:absolute, [0x0d, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora(:absolute, [0x0d, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        subject.a = mask
      end

      it 'ors the accumulator with the provided value' do
        subject.ora(:immediate, [0x09, value])
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora(:immediate, [0x09, value])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora(:immediate, [0x09, value])
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora(:immediate, [0x09, value])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora(:immediate, [0x09, value])
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#pha' do
    let(:top) { 0x1ff }
    let(:value) { 0xbd }

    before do
      subject.a = value
      subject.s = top & 0xff
    end

    it 'pushes a byte onto the stack' do
      expect { subject.pha(:implied, [0x48]) }.to change { subject.s }.by(-1)
    end

    it 'pushes the current accumulator onto the stack' do
      subject.pha(:implied, [0x48])
      expect(memory[top]).to eq(value)
    end

    it 'does not change the current accumulator' do
      expect { subject.pha(:implied, [0x48]) }.not_to change { subject.a }
    end
  end

  describe '#php' do
    let(:top) { 0x1ff }
    let(:value) { 0b11001111 }

    before do
      subject.p = value
      subject.s = top & 0xff
    end

    it 'pushes a byte onto the stack' do
      expect { subject.php(:implied, [0x08]) }.to change { subject.s }.by(-1)
    end

    it 'pushes the current processor status onto the stack' do
      subject.php(:implied, [0x08])
      expect(memory[top] & 0b11001111).to eq(value & 0b11001111)
    end

    it 'pushes the current processor status with the breakpoint flag set' do
      subject.php(:implied, [0x08])
      expect(memory[top] & Vic20::Processor::B_FLAG).to eq(Vic20::Processor::B_FLAG)
    end

    it 'pushes the current processor status with the 5th bit set' do
      subject.php(:implied, [0x08])
      expect(memory[top][5]).to eq(1)
    end

    it 'does not change the current processor status' do
      expect { subject.php(:implied, [0x08]) }.not_to change { subject.p }
    end
  end

  describe '#pla' do
    let(:top) { 0x1ff }
    let(:value) { 0xbd }

    before do
      subject.a = 0
      subject.s = (top - 1) & 0xff
      memory[top] = value
    end

    it 'pulls a byte off of the stack' do
      expect { subject.pla(:implied, [0x68]) }.to change { subject.s }.by(1)
    end

    it 'sets the accumulator to the value pulled off the stack' do
      subject.pla(:implied, [0x68])
      expect(subject.a).to eq(value)
    end

    it 'sets the sign flag' do
      subject.pla(:implied, [0x68])
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.pla(:implied, [0x68])
      expect(subject.z?).to be_falsey
    end

    context 'when the value is 0' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.pla(:implied, [0x68])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.pla(:implied, [0x68])
        expect(subject.z?).to be_truthy
      end
    end
  end

  describe '#plp' do
    let(:top) { 0x1ff }
    let(:value) { 0xbd }

    before do
      subject.p = 0
      subject.s = (top - 1) & 0xff
      memory[top] = value
    end

    it 'pulls a byte off of the stack' do
      expect { subject.plp(:implied, [0x28]) }.to change { subject.s }.by(1)
    end

    it 'sets the processor status to the value pulled off the stack' do
      subject.plp(:implied, [0x28])
      expect(subject.p).to eq(value & ~Vic20::Processor::B_FLAG)
    end

    it 'discards the breakpoint flag when restoring the processor state' do
      subject.plp(:implied, [0x28])
      expect(subject.p & Vic20::Processor::B_FLAG).to eq(0)
    end
  end

  describe '#rol' do
    context 'with absolute addressing mode' do
      let(:address) { 0x4eee }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits left one position' do
        subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
        expect(memory[address]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
          expect(memory[address]).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol(:absolute, [0x2e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:address) { 0x4eee }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory[address + offset] = value
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
        expect(memory[address + offset]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol(:absolute_x, [0x3e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits left one position' do
        subject.rol(:accumulator, [0x2a])
        expect(subject.a).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol(:accumulator, [0x2a])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol(:accumulator, [0x2a])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol(:accumulator, [0x2a])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol(:accumulator, [0x2a])
          expect(subject.a).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol(:accumulator, [0x2a])
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol(:accumulator, [0x2a])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol(:accumulator, [0x2a])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol(:accumulator, [0x2a])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x4e }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits left one position' do
        subject.rol(:zero_page, [0x26, address])
        expect(memory[address]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol(:zero_page, [0x26, address])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol(:zero_page, [0x26, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol(:zero_page, [0x26, address])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol(:zero_page, [0x26, address])
          expect(memory[address]).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol(:zero_page, [0x26, address])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol(:zero_page, [0x26, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol(:zero_page, [0x26, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol(:zero_page, [0x26, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0x4e }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }
      let(:offset) { 1 }

      before do
        subject.p = flags
        memory[(address + offset) & 0xff] = value
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.rol(:zero_page_x, [0x36, address])
        expect(memory[(address + offset) & 0xff]).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol(:zero_page_x, [0x36, address])
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol(:zero_page_x, [0x36, address])
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol(:zero_page_x, [0x36, address])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol(:zero_page_x, [0x36, address])
          expect(memory[(address + offset) & 0xff]).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol(:zero_page_x, [0x36, address])
          expect(memory[(address + offset) & 0xff]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol(:zero_page_x, [0x36, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol(:zero_page_x, [0x36, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol(:zero_page_x, [0x36, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.rol(:zero_page_x, [0x36, address])
          expect(memory[(address + offset) & 0xff]).to eq(value << 1 & 0xff)
        end
      end
    end
  end

  describe '#ror' do
    context 'with absolute addressing mode' do
      let(:address) { 0x5aaa }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits right one position' do
        subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
        expect(memory[address]).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
          expect(memory[address]).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror(:absolute, [0x6e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:address) { 0x5aaa }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory[address + offset] = value
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
        expect(memory[address + offset]).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
          expect(memory[address + offset]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror(:absolute_x, [0x7e, lsb(address), msb(address)])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:value) { 0b01010101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits right one position' do
        subject.ror(:accumulator, [0x6a])
        expect(subject.a).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror(:accumulator, [0x6a])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror(:accumulator, [0x6a])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror(:accumulator, [0x6a])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror(:accumulator, [0x6a])
          expect(subject.a).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror(:accumulator, [0x6a])
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror(:accumulator, [0x6a])
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror(:accumulator, [0x6a])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror(:accumulator, [0x6a])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror(:accumulator, [0x6a])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0x5a }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory[address] = value
      end

      it 'shifts all bits right one position' do
        subject.ror(:zero_page, [0x66, address])
        expect(memory[address]).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror(:zero_page, [0x66, address])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror(:zero_page, [0x66, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror(:zero_page, [0x66, address])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror(:zero_page, [0x66, address])
          expect(memory[address]).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror(:zero_page, [0x66, address])
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror(:zero_page, [0x66, address])
          expect(memory[address]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror(:zero_page, [0x66, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror(:zero_page, [0x66, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror(:zero_page, [0x66, address])
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:address) { 0x5a }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }
      let(:offset) { 4 }

      before do
        subject.p = flags
        memory[(address + offset) & 0xff] = value
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.ror(:zero_page_x, [0x76, address])
        expect(memory[(address + offset) & 0xff]).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror(:zero_page_x, [0x76, address])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror(:zero_page_x, [0x76, address])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror(:zero_page_x, [0x76, address])
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror(:zero_page_x, [0x76, address])
          expect(memory[(address + offset) & 0xff]).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror(:zero_page_x, [0x76, address])
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror(:zero_page_x, [0x76, address])
          expect(memory[(address + offset) & 0xff]).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror(:zero_page_x, [0x76, address])
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror(:zero_page_x, [0x76, address])
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror(:zero_page_x, [0x76, address])
          expect(subject.z?).to be_truthy
        end
      end

      context 'when offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.ror(:zero_page_x, [0x76, address])
          expect(memory[(address + offset) & 0xff]).to eq(value >> 1)
        end
      end
    end
  end

  describe '#rti' do
    let(:top) { 0x1ff }
    let(:pc) { 0x0984 }
    let(:p) { 0x02 | 0b00100000 | Vic20::Processor::B_FLAG }
    let(:irq) { 0xdead }

    before do
      memory[top - 1, 2] = [lsb(pc), msb(pc)]
      memory[top - 2] = subject.p = p
      subject.pc = irq
      subject.s = (top - 3) & 0xff
    end

    it 'pops 3 bytes off the stack' do
      expect { subject.rti(:implied, [0x40]) }.to change { subject.s }.by(3)
    end

    it 'restores the processor status' do
      subject.rti(:implied, [0x40])
      expect(subject.p).to eq(p & ~Vic20::Processor::B_FLAG)
    end

    it 'clears breakpoint flag' do
      subject.rti(:implied, [0x40])
      expect(subject.b?).to be_falsey
    end

    it 'restores the program counter to the saved position' do
      subject.rti(:implied, [0x40])
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#rts' do
    let(:top) { 0x1ff }
    let(:destination) { 0xfd30 }

    before do
      subject.s = (top - 2) & 0xff
      subject.pc = 0xfd4d
      memory[top - 1, 2] = [lsb(destination) - 1, msb(destination)]
    end

    it 'transfers program control to address+1' do
      subject.rts(:implied, [0x60])
      expect(subject.pc).to eq(destination)
    end

    it 'pops a word off the stack' do
      expect { subject.rts(:implied, [0x60]) }.to change { subject.s }.by(2)
    end
  end

  describe '#sbc' do
    let(:a) { 0x19 }
    let(:value) { 0x03 }

    before do
      subject.a = a
      subject.p = 0xff
    end

    context 'with immediate addressing mode' do
      it 'subtracts the value from the accumulator' do
        subject.sbc(:immediate, [0xe9, value])
        expect(subject.a).to eq(a - value)
      end

      it 'sets the carry flag' do
        subject.sbc(:immediate, [0xe9, value])
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.sbc(:immediate, [0xe9, value])
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.sbc(:immediate, [0xe9, value])
        expect(subject.z?).to be_falsey
      end

      context 'when the result < 0' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.sbc(:immediate, [0xe9, value])
          expect(subject.c?).to be_falsey
        end
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x20 }

        it 'sets the sign flag' do
          subject.sbc(:immediate, [0xe9, value])
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is 0' do
        let(:value) { subject.a }

        it 'sets the zero flag' do
          subject.sbc(:immediate, [0xe9, value])
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#sec' do
    before do
      subject.p = 0x00
    end

    it 'sets the carry flag' do
      subject.sec(:implied, [0x38])
      expect(subject.c?).to be_truthy
    end
  end

  describe '#sed' do
    before do
      subject.p = 0x00
    end

    it 'sets the binary-coded decimal flag' do
      subject.sed(:implied, [0xf8])
      expect(subject.d?).to be_truthy
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

  describe '#sta' do
    let(:value) { 0 }

    before do
      subject.a = value
    end

    context 'with absolute addressing mode' do
      let(:address) { 0x0281 }

      before do
        memory[address] = 0xff
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:absolute, [0x8d, lsb(address), msb(address)])
        expect(memory[address]).to eq(value)
      end
    end

    context 'with absolute,x addressing mode' do
      let(:offset) { 0x0f }
      let(:address) { 0x0200 }

      before do
        memory[address + offset] = 0xff
        subject.x = offset
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:absolute_x, [0x9d, lsb(address), msb(address)])
        expect(memory[address + offset]).to eq(value)
      end
    end

    context 'with absolute,y addressing mode' do
      let(:offset) { 0x0f }
      let(:address) { 0x0200 }

      before do
        memory[address + offset] = 0xff
        subject.y = offset
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:absolute_y, [0x99, lsb(address), msb(address)])
        expect(memory[address + offset]).to eq(value)
      end
    end

    context 'with indirect,x addressing mode' do
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0x55 }

      before do
        memory[indirect_address] = 0xff
        memory[(address + offset) & 0xff, 2] = [lsb(indirect_address), msb(indirect_address)]
        subject.x = offset
        subject.a = value
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:indirect_x, [0x81, address])
        expect(memory[indirect_address]).to eq(value)
      end

      context 'when the offset exceed page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.sta(:indirect_x, [0x81, address])
          expect(memory[indirect_address]).to eq(value)
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0x55 }

      before do
        memory[indirect_address + offset] = 0xff
        memory[address, 2] = [lsb(indirect_address), msb(indirect_address)]
        subject.y = offset
        subject.a = value
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:indirect_y, [0x91, address])
        expect(memory[indirect_address + offset]).to eq(value)
      end
    end

    context 'with zero page addressing mode' do
      let(:offset) { 0xc1 }

      before do
        memory[offset] = 0xff
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:zero_page, [0x85, offset])
        expect(memory[offset]).to eq(value)
      end
    end

    context 'with zero page,x addressing mode' do
      let(:offset) { 0x0f }

      before do
        memory[offset] = 0xff
        subject.x = offset
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:zero_page_x, [0x95, 0x00])
        expect(memory[offset]).to eq(value)
      end

      it 'is subject to wrap-around' do
        subject.sta(:zero_page_x, [0x95, 0xff])
        expect(memory[offset - 1]).to eq(value)
      end
    end
  end

  describe '#stx' do
    let(:value) { 0x3c }

    before do
      subject.x = value
    end

    context 'with absolute addressing mode' do
      let(:address) { 0x0283 }

      it 'stores the x-index register value at the correct address' do
        subject.stx(:absolute, [0x8e, lsb(address), msb(address)])
        expect(memory[address]).to eq(value)
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xb2 }

      it 'stores the x-index register value at the correct address' do
        subject.stx(:zero_page, [0x86, address])
        expect(memory[address]).to eq(value)
      end
    end

    context 'with zero page,y addressing mode' do
      let(:address) { 0xb2 }
      let(:offset) { 5 }

      before do
        subject.y = offset
      end

      it 'stores the x-index register value at the correct address' do
        subject.stx(:zero_page_y, [0x96, address])
        expect(memory[address + offset]).to eq(value)
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.stx(:zero_page_y, [0x96, address])
          expect(memory[address + offset - 0x100]).to eq(value)
        end
      end
    end
  end

  describe '#sty' do
    let(:value) { 0x03 }

    before do
      subject.y = value
    end

    context 'with absolute addressing mode' do
      let(:address) { 0x0284 }

      it 'stores the y-index register value at the correct address' do
        subject.sty(:absolute, [0x8c, lsb(address), msb(address)])
        expect(memory[address]).to eq(value)
      end
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xb3 }

      it 'stores the y-index register value at the correct address' do
        subject.sty(:zero_page, [0x84, address])
        expect(memory[address]).to eq(value)
      end
    end

    context 'with zero page,x addressing mode' do
      let(:offset) { 0x0f }

      before do
        memory[offset] = 0xff
        subject.x = offset
      end

      it 'stores the y-index register value at the correct address' do
        subject.sty(:zero_page_x, [0x94, 0x00])
        expect(memory[offset]).to eq(value)
      end

      it 'is subject to wrap-around' do
        subject.sty(:zero_page_x, [0x94, 0xff])
        expect(memory[offset - 1]).to eq(value)
      end
    end
  end

  describe '#tax' do
    let(:value) { 0xff }

    before do
      subject.x = 0xdd
      subject.a = value
    end

    it 'transfers the accumulator to the x-index register' do
      subject.tax(:implied, [0xaa])
      expect(subject.x).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tax(:implied, [0xaa])
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tax(:implied, [0xaa])
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tax(:implied, [0xaa])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tax(:implied, [0xaa])
        expect(subject.z?).to be_truthy
      end
    end
  end

  describe '#tay' do
    let(:value) { 0xff }

    before do
      subject.y = 0xdd
      subject.a = value
    end

    it 'transfers the accumulator to the y-index register' do
      subject.tay(:implied, [0xa8])
      expect(subject.y).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tay(:implied, [0xa8])
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tay(:implied, [0xa8])
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tay(:implied, [0xa8])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tay(:implied, [0xa8])
        expect(subject.z?).to be_truthy
      end
    end
  end

  describe '#tsx' do
    let(:value) { 0xff }

    before do
      subject.x = 0xdd
      subject.s = value
    end

    it 'transfers the stack pointer to the x-index register' do
      subject.tsx(:implied, [0xba])
      expect(subject.x).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tsx(:implied, [0xba])
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tsx(:implied, [0xba])
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tsx(:implied, [0xba])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tsx(:implied, [0xba])
        expect(subject.z?).to be_truthy
      end
    end
  end

  describe '#txa' do
    let(:value) { 0xff }

    before do
      subject.x = value
      subject.a = 0xdd
    end

    it 'transfers the x-index register to the accumulator' do
      subject.txa(:implied, [0x8a])
      expect(subject.a).to eq(value)
    end

    it 'sets the sign flag' do
      subject.txa(:implied, [0x8a])
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.txa(:implied, [0x8a])
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.txa(:implied, [0x8a])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.txa(:implied, [0x8a])
        expect(subject.z?).to be_truthy
      end
    end
  end

  describe '#txs' do
    let(:value) { 0xff }

    before do
      subject.s = 0
      subject.x = value
    end

    it 'transfers the x-index register to the stack pointer' do
      subject.txs(:implied, [0x9a])
      expect(subject.s).to eq(value)
    end
  end

  describe '#tya' do
    let(:value) { 0xff }

    before do
      subject.y = value
      subject.a = 0xdd
    end

    it 'transfers the y-index register to the accumulator' do
      subject.tya(:implied, [0x98])
      expect(subject.a).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tya(:implied, [0x98])
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tya(:implied, [0x98])
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tya(:implied, [0x98])
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tya(:implied, [0x98])
        expect(subject.z?).to be_truthy
      end
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
