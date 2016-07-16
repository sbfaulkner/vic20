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
  end

  describe '#cpy' do
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
  end

  describe '#eor' do
    context 'with zero page,x addressing mode' do
      let(:address) { 0xc1 }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }
      let(:offset) { 0x0e }

      before do
        memory[address + offset] = value
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
    end
  end

  describe '#inc' do
    let(:value) { 0 }

    before do
      memory[address] = value
    end

    context 'with zero page addressing mode' do
      let(:address) { 0xc1 }

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

        it 'increments the x-index register' do
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

  describe '#lda' do
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
  end

  describe '#ldx' do
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
  end

  describe '#ldy' do
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
  end

  describe '#jmp' do
    let(:pc) { 0xfdd2 }
    let(:destination) { 0xfe7b }

    before do
      subject.pc = pc
    end

    it 'transfers program control to the new address' do
      subject.jmp(:absolute, [0x4c, lsb(destination), msb(destination)])
      expect(subject.pc).to eq(destination)
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

  describe '#ror' do
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
  end

  describe '#rts' do
    let(:top) { 0x1ff }
    let(:destination) { 0xfd30 }

    before do
      subject.s = top & 0xff - 2
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
      let(:page) { 0x02 }
      let(:offset) { 0x0f }
      let(:address) { page << 8 | offset }

      before do
        memory[address] = 0xff
        subject.x = offset
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta(:absolute_x, [0x9d, 0x00, page])
        expect(memory[address]).to eq(value)
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
  end

  describe '#sty' do
    let(:value) { 0x03 }

    before do
      subject.y = value
    end

    context 'with zero page addressing mode' do
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
