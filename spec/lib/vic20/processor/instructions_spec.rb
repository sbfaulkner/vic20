require 'spec_helper'

describe Vic20::Processor do
  let(:addressing_mode) { :implied }
  let(:operand) { nil }

  # TODO: refactor signature out into tests that need it
  let(:signature_address) { 0x0d4d }
  let(:signature) { ['A'.ord, '0'.ord, 0xc3, 0xc2, 0xcd] }
  let(:memory) { Vic20::Memory.new([]) }

  subject { described_class.new(memory) }

  before do
    memory.set_bytes(signature_address, 5, signature)
    subject.instance_variable_set :@addressing_mode, addressing_mode
    subject.instance_variable_set :@operand, operand
  end

  describe '#adc' do
    context 'in binary mode' do
      let(:a) { 0x40 }
      let(:value) { 0x0f }

      before do
        subject.a = a
        subject.p = 0x00
      end

      context 'with absolute addressing mode' do
        let(:addressing_mode) { :absolute }
        let(:operand) { address }
        let(:address) { 0x1e3f }

        before do
          memory.set_byte(address, value)
        end

        it 'adds the addressed value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with absolute,x addressing mode' do
        let(:addressing_mode) { :absolute_x }
        let(:operand) { address }
        let(:address) { 0x333f }
        let(:offset) { 0xf5 }

        before do
          memory.set_byte(address + offset, value)
          subject.x = offset
        end

        it 'adds the addressed value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with absolute,y addressing mode' do
        let(:addressing_mode) { :absolute_y }
        let(:operand) { address }
        let(:address) { 0x333f }
        let(:offset) { 0xf5 }

        before do
          memory.set_byte(address + offset, value)
          subject.y = offset
        end

        it 'adds the addressed value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with immediate addressing mode' do
        let(:addressing_mode) { :immediate }
        let(:operand) { value }

        it 'adds the specified value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the overflow flag' do
          subject.adc
          expect(subject.v?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end

        [
          [0x50, 0x10, 0x60, false, false, false],
          [0x50, 0x50, 0xa0, false, true, true],
          [0x50, 0x90, 0xe0, false, true, false],
          [0x50, 0xd0, 0x20, true, false, false],
          [0xd0, 0x10, 0xe0, false, true, false],
          [0xd0, 0x50, 0x20, true, false, false],
          [0xd0, 0x90, 0x60, true, false, true],
          [0xd0, 0xd0, 0xa0, true, true, false],
        ].each do |a, o, r, c, n, v|
          context format('adding 0x%02X to 0x%02X', o, a) do
            let(:operand) { o }

            before do
              subject.p = 0x00
              subject.a = a
            end

            it format('sets the accumulator to 0x%02X', r) do
              subject.adc
              expect(subject.a).to eq(r)
            end

            if c
              it 'sets the carry flag' do
                subject.adc
                expect(subject.c?).to be_truthy
              end
            else
              it 'clears the carry flag' do
                subject.adc
                expect(subject.c?).to be_falsey
              end
            end

            if n
              it 'sets the sign flag' do
                subject.adc
                expect(subject.n?).to be_truthy
              end
            else
              it 'clears the sign flag' do
                subject.adc
                expect(subject.n?).to be_falsey
              end
            end

            if v
              it 'sets the overflow flag' do
                subject.adc
                expect(subject.v?).to be_truthy
              end
            else
              it 'clears the overflow flag' do
                subject.adc
                expect(subject.v?).to be_falsey
              end
            end
          end
        end
      end

      context 'with indirect,x addressing mode' do
        let(:addressing_mode) { :indirect_x }
        let(:operand) { address }
        let(:indirect_address) { 0x333f }
        let(:address) { 0x3f }
        let(:offset) { 5 }

        before do
          memory.set_byte(indirect_address, value)
          memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
          subject.x = offset
        end

        it 'adds the addressed value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end

        context 'when the offset exceeds page bounds' do
          let(:offset) { 0xff }

          it 'wraps around' do
            subject.adc
            expect(subject.a).to eq(a + value)
          end
        end
      end

      context 'with indirect,y addressing mode' do
        let(:addressing_mode) { :indirect_y }
        let(:operand) { address }
        let(:indirect_address) { 0x333f }
        let(:address) { 0x3f }
        let(:offset) { 5 }

        before do
          memory.set_byte(indirect_address + offset, value)
          memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
          subject.y = offset
        end

        it 'adds the addressed value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with zero page addressing mode' do
        let(:addressing_mode) { :zero_page }
        let(:operand) { address }
        let(:address) { 0x3f }

        before do
          memory.set_byte(address, value)
        end

        it 'adds the addressed value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with zero page,x addressing mode' do
        let(:addressing_mode) { :zero_page_x }
        let(:operand) { address }
        let(:address) { 0x3f }
        let(:offset) { 5 }

        before do
          memory.set_byte((address + offset) & 0xff, value)
          subject.x = offset
        end

        it 'adds the addressed value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(a + value)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.adc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.adc
          expect(subject.z?).to be_falsey
        end

        context 'when the result is > 255' do
          let(:a) { 0xfe }

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end

        context 'when the result has incorrect sign' do
          let(:value) { 0x7f }
          let(:a) { 0x7f }

          it 'sets the overflow flag' do
            subject.adc
            expect(subject.v?).to be_truthy
          end

          it 'sets the sign flag' do
            subject.adc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:a) { 0xf1 }

          it 'sets the zero flag' do
            subject.adc
            expect(subject.z?).to be_truthy
          end
        end

        context 'when the offset exceeds page bounds' do
          let(:offset) { 0xff }

          it 'wraps around' do
            subject.adc
            expect(subject.a).to eq(a + value)
          end
        end
      end
    end

    context 'in decimal mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }

      before do
        subject.p = Vic20::Processor::D_FLAG
        subject.a = a
      end

      context 'with the carry flag clear' do
        let(:a) { 0x12 }
        let(:value) { 0x34 }

        # SED      ; Decimal mode (BCD addition: 12 + 34 = 46)
        # CLC
        # LDA #$12
        # ADC #$34 ; After this instruction, C = 0, A = $46
        it 'adds the value to the accumulator' do
          subject.adc
          expect(subject.a).to eq(0x46)
        end

        it 'clears the carry flag' do
          subject.adc
          expect(subject.c?).to be_falsey
        end

        context 'when the result is > 99' do
          let(:a) { 0x81 }
          let(:value) { 0x92 }

          # SED      ; Decimal mode (BCD addition: 81 + 92 = 173)
          # CLC
          # LDA #$81
          # ADC #$92 ; After this instruction, C = 1, A = $73
          it 'adds the value to the accumulator' do
            subject.adc
            expect(subject.a).to eq(0x73)
          end

          it 'sets the carry flag' do
            subject.adc
            expect(subject.c?).to be_truthy
          end
        end
      end

      context 'with the carry flag set' do
        let(:a) { 0x58 }
        let(:value) { 0x46 }

        before do
          subject.p |= Vic20::Processor::C_FLAG
        end

        # SED      ; Decimal mode (BCD addition: 58 + 46 + 1 = 105)
        # SEC      ; Note: carry is set, not clear!
        # LDA #$58
        # ADC #$46 ; After this instruction, C = 1, A = $05
        it 'adds the value and the carry to the accumulator' do
          subject.adc
          expect(subject.a).to eq(0x05)
        end

        it 'sets the carry flag' do
          subject.adc
          expect(subject.c?).to be_truthy
        end
      end
    end
  end

  describe '#and' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1ead }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        memory.set_byte(address, value)
        subject.a = mask
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x1bad }
      let(:offset) { 0xff }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        memory.set_byte(address + offset, value)
        subject.a = mask
        subject.x = offset
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:addressing_mode) { :absolute_y }
      let(:operand) { address }
      let(:address) { 0x1bad }
      let(:offset) { 0xff }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        memory.set_byte(address + offset, value)
        subject.a = mask
        subject.y = offset
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        subject.a = mask
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with indirect,x addressing mode' do
      let(:addressing_mode) { :indirect_x }
      let(:operand) { address }
      let(:indirect_address) { 0x1ead }
      let(:address) { 0x4c }
      let(:offset) { 2 }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        memory.set_byte(indirect_address, value)
        memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.x = offset
        subject.a = mask
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.and
          expect(subject.a).to eq(value & mask)
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:addressing_mode) { :indirect_y }
      let(:operand) { address }
      let(:indirect_address) { 0x1ead }
      let(:address) { 0x4c }
      let(:offset) { 2 }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        memory.set_byte(indirect_address + offset, value)
        memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.y = offset
        subject.a = mask
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xad }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        memory.set_byte(address, value)
        subject.a = mask
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0xad }
      let(:offset) { 5 }
      let(:mask) { 0xfc }
      let(:value) { 0x0f }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.a = mask
        subject.x = offset
      end

      it 'ands the accumulator with the provided value' do
        subject.and
        expect(subject.a).to eq(value & mask)
      end

      it 'clears the sign flag' do
        subject.and
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.and
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.and
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x01 }

        it 'sets the zero flag' do
          subject.and
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.and
          expect(subject.a).to eq(value & mask)
        end
      end
    end
  end

  describe '#asl' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x3e44 }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits left one position' do
        subject.asl
        expect(memory.get_byte(address)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x3e44 }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory.set_byte(address + offset, value)
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.asl
        expect(memory.get_byte(address + offset)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl
          expect(memory.get_byte(address + offset)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:addressing_mode) { :accumulator }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits left one position' do
        subject.asl
        expect(subject.a).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x3e }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits left one position' do
        subject.asl
        expect(memory.get_byte(address)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x3e }
      let(:offset) { 5 }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte((address + offset) & 0xff, value)
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.asl
        expect(memory.get_byte(address + offset)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.asl
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.asl
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.asl
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.asl
          expect(memory.get_byte(address + offset)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.asl
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.asl
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.asl
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.asl
          expect(memory.get_byte(address + offset - 0x100)).to eq(value << 1 & 0xff)
        end
      end
    end
  end

  describe '#bcc' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfdde }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when carry flag is clear' do
      subject.p = 0x00
      subject.bcc
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when carry flag is set' do
      subject.p = 0xff
      subject.bcc
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when carry flag is clear' do
        subject.p = 0x00
        subject.bcc
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#bcs' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfdde }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when carry flag is set' do
      subject.p = 0xff
      subject.bcs
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when carry flag is clear' do
      subject.p = 0x00
      subject.bcs
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when carry flag is set' do
        subject.p = 0xff
        subject.bcs
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#beq' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfdba }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when zero flag is set' do
      subject.p = 0xff
      subject.beq
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when zero flag is clear' do
      subject.p = 0x00
      subject.beq
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when zero flag is set' do
        subject.p = 0xff
        subject.beq
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#bit' do
    let(:mask) { 0x01 }
    let(:value) { 0xc5 }

    before do
      subject.a = mask
      memory.set_byte(address, value)
    end

    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x19a9 }

      it 'sets the sign flag' do
        subject.bit
        expect(subject.n?).to be_truthy
      end

      it 'sets the overflow flag' do
        subject.bit
        expect(subject.v?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.bit
        expect(subject.z?).to be_falsey
      end

      context 'when the 6th and 7th bits of the value are clear' do
        let(:value) { 0x05 }

        it 'clears the sign flag' do
          subject.bit
          expect(subject.n?).to be_falsey
        end

        it 'clears the overflow flag' do
          subject.bit
          expect(subject.v?).to be_falsey
        end
      end

      context 'when the result is zero' do
        let(:mask) { ~value & 0xff }

        it 'sets the zero flag' do
          subject.bit
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xa9 }

      it 'sets the sign flag' do
        subject.bit
        expect(subject.n?).to be_truthy
      end

      it 'sets the overflow flag' do
        subject.bit
        expect(subject.v?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.bit
        expect(subject.z?).to be_falsey
      end

      context 'when the 6th and 7th bits of the value are clear' do
        let(:value) { 0x05 }

        it 'clears the sign flag' do
          subject.bit
          expect(subject.n?).to be_falsey
        end

        it 'clears the overflow flag' do
          subject.bit
          expect(subject.v?).to be_falsey
        end
      end

      context 'when the result is zero' do
        let(:mask) { ~value & 0xff }

        it 'sets the zero flag' do
          subject.bit
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#bmi' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfd49 }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when sign flag is set' do
      subject.p = 0xff
      subject.bmi
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when sign flag is clear' do
      subject.p = 0x00
      subject.bmi
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when sign flag is set' do
        subject.p = 0xff
        subject.bmi
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#bne' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfd49 }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when zero flag is clear' do
      subject.p = 0x00
      subject.bne
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when zero flag is set' do
      subject.p = 0xff
      subject.bne
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when zero flag is clear' do
        subject.p = 0x00
        subject.bne
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#bpl' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfd49 }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when sign flag is clear' do
      subject.p = 0x00
      subject.bpl
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when sign flag is set' do
      subject.p = 0xff
      subject.bpl
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when sign flag is clear' do
        subject.p = 0x00
        subject.bpl
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#brk' do
    let(:pc) { 0x0982 }
    let(:p) { 0x02 }
    let(:top) { 0x1ff }
    let(:irq) { 0xdead }

    before do
      memory.set_bytes(0xfffe, 2, [lsb(irq), msb(irq)])
      subject.s = top & 0xff
      subject.pc = pc
      subject.p = p
    end

    it 'pushes 3 bytes onto the stack' do
      expect { subject.brk }.to change { subject.s }.by(-3)
    end

    it 'pushes the program counter + 1 onto the stack' do
      subject.brk
      expect(memory.get_word(top - 1)).to eq(pc + 1)
    end

    it 'pushes the processor status onto the stack' do
      subject.brk
      expect(memory.get_byte(top - 2) & 0b11001111).to eq(p & 0b11001111)
    end

    it 'pushes the processor status with the breakpoint flag set onto the stack' do
      subject.brk
      expect(memory.get_byte(top - 2) & Vic20::Processor::B_FLAG).to eq(Vic20::Processor::B_FLAG)
    end

    it 'loads the IRQ vector at $fffe into the program counter' do
      subject.brk
      expect(subject.pc).to eq(irq)
    end

    it 'sets the breakpoint flag' do
      subject.brk
      expect(subject.b?).to be_truthy
    end

    it 'sets the interrupt flag' do
      subject.brk
      expect(subject.i?).to be_truthy
    end
  end

  describe '#bvc' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfd49 }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when overflow flag is clear' do
      subject.p = 0x00
      subject.bvc
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when overflow flag is set' do
      subject.p = 0xff
      subject.bvc
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when overflow flag is clear' do
        subject.p = 0x00
        subject.bvc
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#bvs' do
    let(:addressing_mode) { :relative }
    let(:operand) { offset }
    let(:pc) { 0xfd49 }
    let(:offset) { 3 }

    before do
      subject.pc = pc
    end

    it 'branches when overflow flag is set' do
      subject.p = 0xff
      subject.bvs
      expect(subject.pc).to eq(pc + offset)
    end

    it 'does not branch when overflow flag is clear' do
      subject.p = 0x00
      subject.bvs
      expect(subject.pc).to eq(pc)
    end

    context 'with a negative offset' do
      let(:operand) { 0x100 - offset }

      it 'branches backwards when overflow flag is set' do
        subject.p = 0xff
        subject.bvs
        expect(subject.pc).to eq(pc - offset)
      end
    end
  end

  describe '#clc' do
    before do
      subject.p = 0xff
    end

    it 'clears the carry flag' do
      subject.clc
      expect(subject.c?).to be_falsey
    end
  end

  describe '#cld' do
    before do
      subject.p = 0xff
    end

    it 'clears the binary-coded decimal flag' do
      subject.cld
      expect(subject.d?).to be_falsey
    end
  end

  describe '#cli' do
    before do
      subject.p = 0xff
    end

    it 'clears the interrupt flag' do
      subject.cli
      expect(subject.i?).to be_falsey
    end
  end

  describe '#clv' do
    before do
      subject.p = 0xff
    end

    it 'clears the overflow flag' do
      subject.clv
      expect(subject.v?).to be_falsey
    end
  end

  describe '#cmp' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1008 }

      before do
        subject.a = signature[4]
        memory.set_byte(address, value)
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x1003 }

      before do
        subject.a = signature[4]
        subject.x = 0x05
        memory.set_byte(address + 5, value)
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:addressing_mode) { :absolute_y }
      let(:operand) { address }
      let(:address) { 0x1003 }

      before do
        subject.a = signature[4]
        subject.y = 0x05
        memory.set_byte(address + 5, value)
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }

      before do
        subject.a = 0xc5
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { 0xc5 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with indirect,x addressing mode' do
      let(:addressing_mode) { :indirect_x }
      let(:operand) { address }
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }

      before do
        subject.a = 0x80
        memory.set_byte(indirect_address, value)
        memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.x = offset
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end

        context 'when the offset exceeds page bounds' do
          let(:offset) { 0xff }

          it 'wraps around' do
            subject.cmp
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:addressing_mode) { :indirect_y }
      let(:operand) { address }
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }

      before do
        subject.a = 0x80
        memory.set_byte(indirect_address + offset, value)
        memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.y = offset
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x34 }

      before do
        subject.a = 0xc5
        memory.set_byte(address, value)
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x34 }
      let(:offset) { 5 }

      before do
        subject.a = 0xc5
        subject.x = offset
        memory.set_byte((address + offset) & 0xff, value)
      end

      context 'when the accumulator is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the accumulator is equal to the addressed value' do
        let(:value) { subject.a }

        it 'sets the carry flag' do
          subject.cmp
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cmp
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the accumulator is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cmp
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cmp
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cmp
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }
        let(:value) { subject.a }

        it 'wraps around' do
          subject.cmp
          expect(subject.z?).to be_truthy
        end
      end
    end
  end

  describe '#cpx' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1008 }

      before do
        subject.x = signature[4]
        memory.set_byte(address, value)
      end

      context 'when the x-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpx
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpx
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the x-index register is equal to the addressed value' do
        let(:value) { signature[4] }

        it 'sets the carry flag' do
          subject.cpx
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpx
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the x-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpx
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpx
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }

      before do
        subject.x = 0xc5
      end

      context 'when the x-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpx
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpx
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { 0xc5 }

        it 'sets the carry flag' do
          subject.cpx
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpx
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpx
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpx
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x34 }

      before do
        subject.x = 0xc5
        memory.set_byte(address, value)
      end

      context 'when the x-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpx
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpx
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the x-index register is equal to the addressed value' do
        let(:value) { subject.x }

        it 'sets the carry flag' do
          subject.cpx
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpx
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the x-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpx
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpx
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpx
          expect(subject.z?).to be_falsey
        end
      end
    end
  end

  describe '#cpy' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1008 }

      before do
        subject.y = signature[4]
        memory.set_byte(address, value)
      end

      context 'when the y-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpy
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpy
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { subject.y }

        it 'sets the carry flag' do
          subject.cpy
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpy
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpy
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpy
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }

      before do
        subject.y = 0xc5
      end

      context 'when the y-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpy
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpy
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { 0xc5 }

        it 'sets the carry flag' do
          subject.cpy
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpy
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpy
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpy
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x34 }

      before do
        subject.y = 0xc5
        memory.set_byte(address, value)
      end

      context 'when the y-index register is greater than the addressed value' do
        let(:value) { 0x00 }

        it 'sets the carry flag' do
          subject.cpy
          expect(subject.c?).to be_truthy
        end

        it 'sets the sign flag' do
          subject.cpy
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the y-index register is equal to the addressed value' do
        let(:value) { subject.y }

        it 'sets the carry flag' do
          subject.cpy
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.cpy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.cpy
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the y-index register is less than the addressed value' do
        let(:value) { 0xff }

        it 'clears the carry flag' do
          subject.cpy
          expect(subject.c?).to be_falsey
        end

        it 'sets the sign flag' do
          subject.cpy
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.cpy
          expect(subject.z?).to be_falsey
        end
      end
    end
  end

  describe '#dec' do
    let(:value) { 1 }

    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x111a }

      before do
        memory.set_byte(address, value)
      end

      it 'decrements the value' do
        subject.dec
        expect(memory.get_byte(address)).to eq(value - 1)
      end

      it 'clears the sign flag' do
        subject.dec
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.dec
        expect(subject.z?).to be_truthy
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'decrements the value' do
          subject.dec
          expect(memory.get_byte(address)).to eq(value - 1)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0' do
        let(:value) { 0 }

        it 'rolls over to 0xff' do
          subject.dec
          expect(memory.get_byte(address)).to eq(0xff)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x111a }
      let(:offset) { 0xee }

      before do
        memory.set_byte(address + offset, value)
        subject.x = offset
      end

      it 'decrements the value' do
        subject.dec
        expect(memory.get_byte(address + offset)).to eq(value - 1)
      end

      it 'clears the sign flag' do
        subject.dec
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.dec
        expect(subject.z?).to be_truthy
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'decrements the value' do
          subject.dec
          expect(memory.get_byte(address + offset)).to eq(value - 1)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0' do
        let(:value) { 0 }

        it 'rolls over to 0xff' do
          subject.dec
          expect(memory.get_byte(address + offset)).to eq(0xff)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x1a }

      before do
        memory.set_byte(address, value)
      end

      it 'decrements the value' do
        subject.dec
        expect(memory.get_byte(address)).to eq(value - 1)
      end

      it 'clears the sign flag' do
        subject.dec
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.dec
        expect(subject.z?).to be_truthy
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'decrements the value' do
          subject.dec
          expect(memory.get_byte(address)).to eq(value - 1)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0' do
        let(:value) { 0 }

        it 'rolls over to 0xff' do
          subject.dec
          expect(memory.get_byte(address)).to eq(0xff)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x1a }
      let(:offset) { 0xa1 }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.x = offset
      end

      it 'decrements the value' do
        subject.dec
        expect(memory.get_byte((address + offset) & 0xff)).to eq(value - 1)
      end

      it 'clears the sign flag' do
        subject.dec
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.dec
        expect(subject.z?).to be_truthy
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'decrements the value' do
          subject.dec
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value - 1)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0' do
        let(:value) { 0 }

        it 'rolls over to 0xff' do
          subject.dec
          expect(memory.get_byte((address + offset) & 0xff)).to eq(0xff)
        end

        it 'sets the sign flag' do
          subject.dec
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.dec
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.dec
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value - 1)
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
      subject.dex
      expect(subject.x).to eq(x - 1)
    end

    it 'clears the sign flag' do
      subject.dex
      expect(subject.n?).to be_falsey
    end

    it 'sets the zero flag' do
      subject.dex
      expect(subject.z?).to be_truthy
    end

    context 'when the initial value is 0xff' do
      let(:x) { 0xff }

      it 'decrements the x-index register' do
        subject.dex
        expect(subject.x).to eq(x - 1)
      end

      it 'sets the sign flag' do
        subject.dex
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dex
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0' do
      let(:x) { 0 }

      it 'rolls over to 0xff' do
        subject.dex
        expect(subject.x).to eq(0xff)
      end

      it 'sets the sign flag' do
        subject.dex
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dex
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
      subject.dey
      expect(subject.y).to eq(y - 1)
    end

    it 'clears the sign flag' do
      subject.dey
      expect(subject.n?).to be_falsey
    end

    it 'sets the zero flag' do
      subject.dey
      expect(subject.z?).to be_truthy
    end

    context 'when the initial value is 0xff' do
      let(:y) { 0xff }

      it 'decrements the y-index register' do
        subject.dey
        expect(subject.y).to eq(y - 1)
      end

      it 'sets the sign flag' do
        subject.dey
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dey
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0' do
      let(:y) { 0 }

      it 'rolls over to 0xff' do
        subject.dey
        expect(subject.y).to eq(0xff)
      end

      it 'sets the sign flag' do
        subject.dey
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.dey
        expect(subject.z?).to be_falsey
      end
    end
  end

  describe '#eor' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1b0e }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }

      before do
        memory.set_byte(address, value)
        subject.a = mask
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x1bc1 }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }
      let(:offset) { 0x2e }

      before do
        memory.set_byte(address + offset, value)
        subject.a = mask
        subject.x = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:addressing_mode) { :absolute_y }
      let(:operand) { address }
      let(:address) { 0x1bc1 }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }
      let(:offset) { 0x2e }

      before do
        memory.set_byte(address + offset, value)
        subject.a = mask
        subject.y = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }

      before do
        subject.a = mask
      end

      it 'xors the accumulator with the value' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with indirect,x addressing mode' do
      let(:addressing_mode) { :indirect_x }
      let(:operand) { address }
      let(:indirect_address) { 0x1bc1 }
      let(:address) { 0x9e }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }
      let(:offset) { 0x2e }

      before do
        memory.set_byte(indirect_address, value)
        memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.a = mask
        subject.x = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:addressing_mode) { :indirect_y }
      let(:operand) { address }
      let(:indirect_address) { 0x1bc1 }
      let(:address) { 0x9e }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }
      let(:offset) { 0x2e }

      before do
        memory.set_byte(indirect_address + offset, value)
        memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.a = mask
        subject.y = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xc1 }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }

      before do
        memory.set_byte(address, value)
        subject.a = mask
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0xc1 }
      let(:mask) { 0x3c }
      let(:value) { 0x0f }
      let(:offset) { 0x0e }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.a = mask
        subject.x = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.eor
        expect(subject.a).to eq(value ^ mask)
      end

      it 'clears the sign flag' do
        subject.eor
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.eor
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0x80 }

        it 'sets the sign flag' do
          subject.eor
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:value) { 0x3c }

        it 'sets the zero flag' do
          subject.eor
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.eor
          expect(subject.a).to eq(value ^ mask)
        end
      end
    end
  end

  describe '#inc' do
    let(:value) { 0 }

    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1c05 }

      before do
        memory.set_byte(address, value)
      end

      it 'increments the value at the specified address' do
        subject.inc
        expect(memory.get_byte(address)).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc
          expect(memory.get_byte(address)).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc
          expect(memory.get_byte(address)).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x1cd5 }
      let(:offset) { 0xbb }

      before do
        memory.set_byte(address + offset, value)
        subject.x = offset
      end

      it 'increments the value at the specified address' do
        subject.inc
        expect(memory.get_byte(address + offset)).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc
          expect(memory.get_byte(address + offset)).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc
          expect(memory.get_byte(address + offset)).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xc1 }

      before do
        memory.set_byte(address, value)
      end

      it 'increments the value at the specified address' do
        subject.inc
        expect(memory.get_byte(address)).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc
          expect(memory.get_byte(address)).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc
          expect(memory.get_byte(address)).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0xc1 }
      let(:offset) { 0x18 }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.x = offset
      end

      it 'increments the value at the specified address' do
        subject.inc
        expect(memory.get_byte((address + offset) & 0xff)).to eq(value + 1)
      end

      it 'clears the sign flag' do
        subject.inc
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.inc
        expect(subject.z?).to be_falsey
      end

      context 'when the initial value is 0x7f' do
        let(:value) { 0x7f }

        it 'increments the value at the specified address' do
          subject.inc
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value + 1)
        end

        it 'sets the sign flag' do
          subject.inc
          expect(subject.n?).to be_truthy
        end

        it 'clears the zero flag' do
          subject.inc
          expect(subject.z?).to be_falsey
        end
      end

      context 'when the initial value is 0xff' do
        let(:value) { 0xff }

        it 'rolls over to zero' do
          subject.inc
          expect(memory.get_byte((address + offset) & 0xff)).to eq(0)
        end

        it 'clears the sign flag' do
          subject.inc
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.inc
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.inc
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value + 1)
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
      subject.inx
      expect(subject.x).to eq(x + 1)
    end

    it 'clears the sign flag' do
      subject.inx
      expect(subject.n?).to be_falsey
    end

    it 'clears the zero flag' do
      subject.inx
      expect(subject.z?).to be_falsey
    end

    context 'when the initial value is 0x7f' do
      let(:x) { 0x7f }

      it 'increments the x-index register' do
        subject.inx
        expect(subject.x).to eq(x + 1)
      end

      it 'sets the sign flag' do
        subject.inx
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.inx
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0xff' do
      let(:x) { 0xff }

      it 'rolls over to zero' do
        subject.inx
        expect(subject.x).to eq(0)
      end

      it 'clears the sign flag' do
        subject.inx
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.inx
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
      subject.iny
      expect(subject.y).to eq(y + 1)
    end

    it 'clears the sign flag' do
      subject.iny
      expect(subject.n?).to be_falsey
    end

    it 'clears the zero flag' do
      subject.iny
      expect(subject.z?).to be_falsey
    end

    context 'when the initial value is 0x7f' do
      let(:y) { 0x7f }

      it 'increments the x-index register' do
        subject.iny
        expect(subject.y).to eq(y + 1)
      end

      it 'sets the sign flag' do
        subject.iny
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.iny
        expect(subject.z?).to be_falsey
      end
    end

    context 'when the initial value is 0xff' do
      let(:y) { 0xff }

      it 'rolls over to zero' do
        subject.iny
        expect(subject.y).to eq(0)
      end

      it 'clears the sign flag' do
        subject.iny
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.iny
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
      let(:addressing_mode) { :absolute }
      let(:operand) { destination }

      it 'transfers program control to the new address' do
        subject.jmp
        expect(subject.pc).to eq(destination)
      end
    end

    context 'with indirect addressing mode' do
      let(:addressing_mode) { :indirect }
      let(:operand) { address }
      let(:address) { 0xc000 }

      before do
        memory.set_bytes(address, 2, [lsb(destination), msb(destination)])
      end

      it 'transfers program control to the new address' do
        subject.jmp
        expect(subject.pc).to eq(destination)
      end
    end
  end

  describe '#jsr' do
    let(:addressing_mode) { :absolute }
    let(:operand) { destination }
    let(:top) { 0x1ff }
    let(:pc) { 0xfd27 }
    let(:destination) { 0xfd3f }

    before do
      subject.s = top & 0xff
      subject.pc = pc
    end

    it 'pushes a word onto the stack' do
      expect { subject.jsr }.to change { subject.s }.by(-2)
    end

    it 'pushes address-1 to the stack' do
      subject.jsr
      expect(memory.get_word(top - 1)).to eq(pc - 1)
    end

    it 'transfers program control to the new address' do
      subject.jsr
      expect(subject.pc).to eq(destination)
    end
  end

  describe '#lda' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { signature_address + 4 }
      let(:value) { signature[4] }

      before do
        subject.a = 0x00
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        before do
          memory.set_byte(address, 0)
        end

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { signature_address - 1 }
      let(:value) { signature[4] }

      before do
        subject.a = 0x00
        subject.x = 5
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        before do
          memory.set_byte(address + 5, 0)
        end

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:addressing_mode) { :absolute_y }
      let(:operand) { address }
      let(:address) { signature_address - 1 }
      let(:value) { signature[4] }

      before do
        subject.a = 0x00
        subject.y = 5
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        before do
          memory.set_byte(address + 5, 0)
        end

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing_mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }
      let(:value) { 0xff }

      before do
        subject.a = 0x00
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with indirect,x addressing mode' do
      let(:addressing_mode) { :indirect_x }
      let(:operand) { address }
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0xff }

      before do
        memory.set_byte(indirect_address, value)
        memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.lda
          expect(subject.a).to eq(value)
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:addressing_mode) { :indirect_y }
      let(:operand) { address }
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0xff }

      before do
        memory.set_byte(indirect_address + offset, value)
        memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.y = offset
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x9 }
      let(:value) { 0xff }

      before do
        memory.set_byte(address, value)
        subject.a = 0x00
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x09 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.a = 0x00
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.lda
        expect(subject.a).to eq(value)
      end

      it 'sets the sign flag' do
        subject.lda
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.lda
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.lda
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lda
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.lda
          expect(subject.a).to eq(value)
        end
      end
    end
  end

  describe '#ldx' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1c5a }
      let(:value) { 0xff }

      before do
        memory.set_byte(address, value)
        subject.x = 0x00
      end

      it 'sets the x index register to the value' do
        subject.ldx
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:addressing_mode) { :absolute_y }
      let(:operand) { address }
      let(:address) { 0x09a0 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory.set_byte(address + offset, value)
        subject.x = 0x00
        subject.y = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldx
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }
      let(:value) { 0xff }

      before do
        subject.x = 0x00
      end

      it 'sets the x index register to the value' do
        subject.ldx
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xc1 }
      let(:value) { 0xff }

      before do
        memory.set_byte(address, value)
        subject.x = 0x00
      end

      it 'sets the x index register to the value' do
        subject.ldx
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,y addressing mode' do
      let(:addressing_mode) { :zero_page_y }
      let(:operand) { address }
      let(:address) { 0x09 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.x = 0x00
        subject.y = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldx
        expect(subject.x).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldx
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldx
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldx
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldx
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.ldx
          expect(subject.x).to eq(value)
        end
      end
    end
  end

  describe '#ldy' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1ca8 }
      let(:value) { 0xff }

      before do
        memory.set_byte(address, value)
        subject.y = 0x00
      end

      it 'sets the y index register to the value' do
        subject.ldy
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x1309 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory.set_byte(address + offset, value)
        subject.y = 0x00
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldy
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }
      let(:value) { 0xff }

      before do
        subject.y = 0x00
      end

      it 'sets the y index register to the value' do
        subject.ldy
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xc2 }
      let(:value) { 0xff }

      before do
        memory.set_byte(address, value)
        subject.y = 0x00
      end

      it 'sets the y index register to the value' do
        subject.ldy
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x09 }
      let(:offset) { 5 }
      let(:value) { 0xc5 }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.y = 0x00
        subject.x = offset
      end

      it 'sets the accumulator to the value' do
        subject.ldy
        expect(subject.y).to eq(value)
      end

      it 'sets the sign flag' do
        subject.ldy
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag' do
        subject.ldy
        expect(subject.z?).to be_falsey
      end

      context 'when the value is zero' do
        let(:value) { 0 }

        it 'clears the sign flag' do
          subject.ldy
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ldy
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.ldy
          expect(subject.y).to eq(value)
        end
      end
    end
  end

  describe '#lsr' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x1e44 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits right one position' do
        subject.lsr
        expect(memory.get_byte(address)).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x1e44 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory.set_byte(address + offset, value)
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.lsr
        expect(memory.get_byte(address + offset)).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr
          expect(memory.get_byte(address + offset)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:addressing_mode) { :accumulator }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits right one position' do
        subject.lsr
        expect(subject.a).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xe4 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits right one position' do
        subject.lsr
        expect(memory.get_byte(address)).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0xe4 }
      let(:value) { 0b01110101 }
      let(:flags) { 0 }
      let(:offset) { 5 }

      before do
        subject.p = flags
        memory.set_byte((address + offset) & 0xff, value)
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.lsr
        expect(memory.get_byte((address + offset) & 0xff)).to eq(value >> 1 & 0xff)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.lsr
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.lsr
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.lsr
        expect(subject.z?).to be_falsey
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.lsr
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.lsr
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.lsr
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.lsr
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.lsr
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value >> 1 & 0xff)
        end
      end
    end
  end

  describe '#nop' do
    it 'is successful' do
      expect { subject.nop }.not_to raise_exception
    end
  end

  describe '#ora' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x0288 }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory.set_byte(address, value)
        subject.a = mask
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x0288 }
      let(:offset) { 0xff }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory.set_byte(address + offset, value)
        subject.a = mask
        subject.x = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,y addressing mode' do
      let(:addressing_mode) { :absolute_y }
      let(:operand) { address }
      let(:address) { 0x0288 }
      let(:offset) { 0xff }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory.set_byte(address + offset, value)
        subject.a = mask
        subject.y = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with immediate addressing mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        subject.a = mask
      end

      it 'ors the accumulator with the provided value' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with indirect,x addressing mode' do
      let(:addressing_mode) { :indirect_x }
      let(:operand) { address }
      let(:indirect_address) { 0x0288 }
      let(:address) { 0x28 }
      let(:offset) { 0xff }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory.set_byte(indirect_address, value)
        memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.a = mask
        subject.x = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:addressing_mode) { :indirect_y }
      let(:operand) { address }
      let(:indirect_address) { 0x0288 }
      let(:address) { 0x28 }
      let(:offset) { 0xff }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory.set_byte(indirect_address + offset, value)
        memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.a = mask
        subject.y = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x88 }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory.set_byte(address, value)
        subject.a = mask
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x88 }
      let(:offset) { 0x08 }
      let(:mask) { 0x1c }
      let(:value) { 0x45 }

      before do
        memory.set_byte((address + offset) & 0xff, value)
        subject.a = mask
        subject.x = offset
      end

      it 'xors the accumulator with the value at the specified address' do
        subject.ora
        expect(subject.a).to eq(value | mask)
      end

      it 'clears the sign flag' do
        subject.ora
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag' do
        subject.ora
        expect(subject.z?).to be_falsey
      end

      context 'when the result has bit 7 set' do
        let(:value) { 0xc5 }

        it 'sets the sign flag' do
          subject.ora
          expect(subject.n?).to be_truthy
        end
      end

      context 'when the result is zero' do
        let(:mask) { 0 }
        let(:value) { 0 }

        it 'sets the zero flag' do
          subject.ora
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.ora
          expect(subject.a).to eq(value | mask)
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
      expect { subject.pha }.to change { subject.s }.by(-1)
    end

    it 'pushes the current accumulator onto the stack' do
      subject.pha
      expect(memory.get_byte(top)).to eq(value)
    end

    it 'does not change the current accumulator' do
      expect { subject.pha }.not_to change { subject.a }
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
      expect { subject.php }.to change { subject.s }.by(-1)
    end

    it 'pushes the current processor status onto the stack' do
      subject.php
      expect(memory.get_byte(top) & 0b11001111).to eq(value & 0b11001111)
    end

    it 'pushes the current processor status with the breakpoint flag set' do
      subject.php
      expect(memory.get_byte(top) & Vic20::Processor::B_FLAG).to eq(Vic20::Processor::B_FLAG)
    end

    it 'pushes the current processor status with the 5th bit set' do
      subject.php
      expect(memory.get_byte(top)[5]).to eq(1)
    end

    it 'does not change the current processor status' do
      expect { subject.php }.not_to change { subject.p }
    end
  end

  describe '#pla' do
    let(:top) { 0x1ff }
    let(:value) { 0xbd }

    before do
      subject.a = 0
      subject.s = (top - 1) & 0xff
      memory.set_byte(top, value)
    end

    it 'pulls a byte off of the stack' do
      expect { subject.pla }.to change { subject.s }.by(1)
    end

    it 'sets the accumulator to the value pulled off the stack' do
      subject.pla
      expect(subject.a).to eq(value)
    end

    it 'sets the sign flag' do
      subject.pla
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.pla
      expect(subject.z?).to be_falsey
    end

    context 'when the value is 0' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.pla
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.pla
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
      memory.set_byte(top, value)
    end

    it 'pulls a byte off of the stack' do
      expect { subject.plp }.to change { subject.s }.by(1)
    end

    it 'sets the processor status to the value pulled off the stack' do
      subject.plp
      expect(subject.p).to eq(value & ~Vic20::Processor::B_FLAG)
    end

    it 'discards the breakpoint flag when restoring the processor state' do
      subject.plp
      expect(subject.p & Vic20::Processor::B_FLAG).to eq(0)
    end
  end

  describe '#rol' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x4eee }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits left one position' do
        subject.rol
        expect(memory.get_byte(address)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol
          expect(memory.get_byte(address)).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x4eee }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory.set_byte(address + offset, value)
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.rol
        expect(memory.get_byte(address + offset)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol
          expect(memory.get_byte(address + offset)).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol
          expect(memory.get_byte(address + offset)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:addressing_mode) { :accumulator }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits left one position' do
        subject.rol
        expect(subject.a).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol
          expect(subject.a).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x4e }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits left one position' do
        subject.rol
        expect(memory.get_byte(address)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol
          expect(memory.get_byte(address)).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x4e }
      let(:value) { 0b11101010 }
      let(:flags) { 0 }
      let(:offset) { 1 }

      before do
        subject.p = flags
        memory.set_byte((address + offset) & 0xff, value)
        subject.x = offset
      end

      it 'shifts all bits left one position' do
        subject.rol
        expect(memory.get_byte((address + offset) & 0xff)).to eq(value << 1 & 0xff)
      end

      it 'shifts bit 7 into the carry flag' do
        subject.rol
        expect(subject.c?).to be_truthy
      end

      it 'sets the sign flag' do
        subject.rol
        expect(subject.n?).to be_truthy
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.rol
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 0' do
          subject.rol
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value << 1 & 0xff | 0x01)
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.rol
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.rol
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.rol
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.rol
          expect(subject.z?).to be_truthy
        end
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.rol
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value << 1 & 0xff)
        end
      end
    end
  end

  describe '#ror' do
    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x5aaa }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits right one position' do
        subject.ror
        expect(memory.get_byte(address)).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror
          expect(memory.get_byte(address)).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:address) { 0x5aaa }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }
      let(:offset) { 0xcc }

      before do
        subject.p = flags
        memory.set_byte(address + offset, value)
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.ror
        expect(memory.get_byte(address + offset)).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror
          expect(memory.get_byte(address + offset)).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror
          expect(memory.get_byte(address + offset)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with accumulator addressing mode' do
      let(:addressing_mode) { :accumulator }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        subject.a = value
      end

      it 'shifts all bits right one position' do
        subject.ror
        expect(subject.a).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror
          expect(subject.a).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror
          expect(subject.a).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0x5a }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }

      before do
        subject.p = flags
        memory.set_byte(address, value)
      end

      it 'shifts all bits right one position' do
        subject.ror
        expect(memory.get_byte(address)).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror
          expect(memory.get_byte(address)).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror
          expect(memory.get_byte(address)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror
          expect(subject.z?).to be_truthy
        end
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x5a }
      let(:value) { 0b01010101 }
      let(:flags) { 0 }
      let(:offset) { 4 }

      before do
        subject.p = flags
        memory.set_byte((address + offset) & 0xff, value)
        subject.x = offset
      end

      it 'shifts all bits right one position' do
        subject.ror
        expect(memory.get_byte((address + offset) & 0xff)).to eq(value >> 1)
      end

      it 'shifts bit 0 into the carry flag' do
        subject.ror
        expect(subject.c?).to be_truthy
      end

      it 'clears the sign flag' do
        subject.ror
        expect(subject.n?).to be_falsey
      end

      it 'clears the zero flag when the value is non-zero' do
        subject.ror
        expect(subject.z?).to be_falsey
      end

      context 'with the carry flag set' do
        let(:flags) { 0xff }

        it 'shifts the carry flag into bit 7' do
          subject.ror
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value >> 1 | 0x80)
        end

        it 'sets the sign flag' do
          subject.ror
          expect(subject.n?).to be_truthy
        end
      end

      context 'with a value of zero' do
        let(:value) { 0 }

        it 'has a value of zero' do
          subject.ror
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value)
        end

        it 'clears the carry flag' do
          subject.ror
          expect(subject.c?).to be_falsey
        end

        it 'clears the sign flag' do
          subject.ror
          expect(subject.n?).to be_falsey
        end

        it 'sets the zero flag' do
          subject.ror
          expect(subject.z?).to be_truthy
        end
      end

      context 'when offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.ror
          expect(memory.get_byte((address + offset) & 0xff)).to eq(value >> 1)
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
      memory.set_bytes(top - 1, 2, [lsb(pc), msb(pc)])
      memory.set_byte(top - 2, subject.p = p)
      subject.pc = irq
      subject.s = (top - 3) & 0xff
    end

    it 'pops 3 bytes off the stack' do
      expect { subject.rti }.to change { subject.s }.by(3)
    end

    it 'restores the processor status' do
      subject.rti
      expect(subject.p).to eq(p & ~Vic20::Processor::B_FLAG)
    end

    it 'clears breakpoint flag' do
      subject.rti
      expect(subject.b?).to be_falsey
    end

    it 'restores the program counter to the saved position' do
      subject.rti
      expect(subject.pc).to eq(pc)
    end
  end

  describe '#rts' do
    let(:top) { 0x1ff }
    let(:destination) { 0xfd30 }

    before do
      subject.s = (top - 2) & 0xff
      subject.pc = 0xfd4d
      memory.set_bytes(top - 1, 2, [lsb(destination) - 1, msb(destination)])
    end

    it 'transfers program control to address+1' do
      subject.rts
      expect(subject.pc).to eq(destination)
    end

    it 'pops a word off the stack' do
      expect { subject.rts }.to change { subject.s }.by(2)
    end
  end

  describe '#sbc' do
    context 'in binary mode' do
      let(:a) { 0x19 }
      let(:value) { 0x03 }

      before do
        subject.a = a
        subject.p = Vic20::Processor::C_FLAG # no borrow
      end

      context 'with absolute addressing mode' do
        let(:addressing_mode) { :absolute }
        let(:operand) { address }
        let(:address) { 0x1dd1 }

        before do
          memory.set_byte(address, value)
        end

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { 0x19 }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with absolute,x addressing mode' do
        let(:addressing_mode) { :absolute_x }
        let(:operand) { address }
        let(:address) { 0x1dd1 }
        let(:offset) { 0xd5 }

        before do
          memory.set_byte(address + offset, value)
          subject.x = offset
        end

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { subject.a }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with absolute,y addressing mode' do
        let(:addressing_mode) { :absolute_y }
        let(:operand) { address }
        let(:address) { 0x1dd1 }
        let(:offset) { 0xd5 }

        before do
          memory.set_byte(address + offset, value)
          subject.y = offset
        end

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { subject.a }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with immediate addressing mode' do
        let(:addressing_mode) { :immediate }
        let(:operand) { value }

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { a }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end

        [
          [0x50, 0xf0, 0x60, false, false, false],
          [0x50, 0xb0, 0xa0, false, true, true],
          [0x50, 0x70, 0xe0, false, true, false],
          [0x50, 0x30, 0x20, true, false, false],
          [0xd0, 0xf0, 0xe0, false, true, false],
          [0xd0, 0xb0, 0x20, true, false, false],
          [0xd0, 0x70, 0x60, true, false, true],
          [0xd0, 0x30, 0xa0, true, true, false],
        ].each do |a, o, r, c, n, v|
          context format('subtracting 0x%02X from 0x%02X', o, a) do
            let(:operand) { o }

            before do
              subject.p = 0x01
              subject.a = a
            end

            it format('sets the accumulator to 0x%02X', r) do
              subject.sbc
              expect(subject.a).to eq(r)
            end

            if c
              it 'sets the carry flag' do
                subject.sbc
                expect(subject.c?).to be_truthy
              end
            else
              it 'clears the carry flag' do
                subject.sbc
                expect(subject.c?).to be_falsey
              end
            end

            if n
              it 'sets the sign flag' do
                subject.sbc
                expect(subject.n?).to be_truthy
              end
            else
              it 'clears the sign flag' do
                subject.sbc
                expect(subject.n?).to be_falsey
              end
            end

            if v
              it 'sets the overflow flag' do
                subject.sbc
                expect(subject.v?).to be_truthy
              end
            else
              it 'clears the overflow flag' do
                subject.sbc
                expect(subject.v?).to be_falsey
              end
            end
          end
        end
      end

      context 'with indirect,x addressing mode' do
        let(:addressing_mode) { :indirect_x }
        let(:operand) { address }
        let(:indirect_address) { 0x1dd1 }
        let(:address) { 0xd1 }
        let(:offset) { 5 }

        before do
          memory.set_byte(indirect_address, value)
          memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
          subject.x = offset
        end

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { subject.a }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end

        context 'when the offset exceeds page bounds' do
          let(:offset) { 0xff }

          it 'wraps around' do
            subject.sbc
            expect(subject.a).to eq(a - value)
          end
        end
      end

      context 'with indirect,y addressing mode' do
        let(:addressing_mode) { :indirect_y }
        let(:operand) { address }
        let(:indirect_address) { 0x1dd1 }
        let(:address) { 0xd1 }
        let(:offset) { 5 }

        before do
          memory.set_byte(indirect_address + offset, value)
          memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
          subject.y = offset
        end

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { subject.a }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end

        context 'when the offset exceeds page bounds' do
          let(:offset) { 0xff }

          it 'wraps around' do
            subject.sbc
            expect(subject.a).to eq(a - value)
          end
        end
      end

      context 'with zero page addressing mode' do
        let(:addressing_mode) { :zero_page }
        let(:operand) { address }
        let(:address) { 0xd1 }

        before do
          memory.set_byte(address, value)
        end

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { subject.a }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end
      end

      context 'with zero page,x addressing mode' do
        let(:addressing_mode) { :zero_page_x }
        let(:operand) { address }
        let(:address) { 0xd1 }
        let(:offset) { 5 }

        before do
          memory.set_byte((address + offset) & 0xff, value)
          subject.x = offset
        end

        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(a - value)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        it 'clears the sign flag' do
          subject.sbc
          expect(subject.n?).to be_falsey
        end

        it 'clears the zero flag' do
          subject.sbc
          expect(subject.z?).to be_falsey
        end

        context 'when the result < 0' do
          let(:value) { 0xff }

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end

        context 'when the result has bit 7 set' do
          let(:value) { 0x20 }

          it 'sets the sign flag' do
            subject.sbc
            expect(subject.n?).to be_truthy
          end
        end

        context 'when the result is 0' do
          let(:value) { subject.a }

          it 'sets the zero flag' do
            subject.sbc
            expect(subject.z?).to be_truthy
          end
        end

        context 'when the offset exceeds page bounds' do
          let(:offset) { 0xff }

          it 'wraps around' do
            subject.sbc
            expect(subject.a).to eq(a - value)
          end
        end
      end
    end

    context 'in decimal mode' do
      let(:addressing_mode) { :immediate }
      let(:operand) { value }

      before do
        subject.p = Vic20::Processor::D_FLAG
        subject.a = a
      end

      context 'with the carry flag set' do
        let(:a) { 0x46 }
        let(:value) { 0x12 }

        before do
          subject.p |= Vic20::Processor::C_FLAG # no borrow
        end

        # SED      ; Decimal mode (BCD subtraction: 46 - 12 = 34)
        # SEC
        # LDA #$46
        # SBC #$12 ; After this instruction, C = 1, A = $34)
        it 'subtracts the value from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(0x34)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end

        context 'when the result is < 0' do
          let(:a) { 0x21 }
          let(:value) { 0x34 }

          # SED      ; Decimal mode (BCD subtraction: 21 - 34)
          # SEC
          # LDA #$21
          # SBC #$34 ; After this instruction, C = 0, A = $87)
          it 'subtracts the value from the accumulator' do
            subject.sbc
            expect(subject.a).to eq(0x87)
          end

          it 'clears the carry flag' do
            subject.sbc
            expect(subject.c?).to be_falsey
          end
        end
      end

      context 'with the carry flag clear' do
        let(:a) { 0x32 }
        let(:value) { 0x02 }

        before do
          subject.p &= ~Vic20::Processor::C_FLAG # borrow
        end

        # SED      ; Decimal mode (BCD subtraction: 32 - 2 - 1 = 29)
        # CLC      ; Note: carry is clear, not set!
        # LDA #$32
        # SBC #$02 ; After this instruction, C = 1, A = $29)
        it 'subtracts the value and the borrow from the accumulator' do
          subject.sbc
          expect(subject.a).to eq(0x29)
        end

        it 'sets the carry flag' do
          subject.sbc
          expect(subject.c?).to be_truthy
        end
      end
    end
  end

  describe '#sec' do
    before do
      subject.p = 0x00
    end

    it 'sets the carry flag' do
      subject.sec
      expect(subject.c?).to be_truthy
    end
  end

  describe '#sed' do
    before do
      subject.p = 0x00
    end

    it 'sets the binary-coded decimal flag' do
      subject.sed
      expect(subject.d?).to be_truthy
    end
  end

  describe '#sei' do
    before do
      subject.p = 0x00
    end

    it 'sets the interrupt flag' do
      subject.sei
      expect(subject.i?).to be_truthy
    end
  end

  describe '#sta' do
    let(:value) { 0 }

    before do
      subject.a = value
    end

    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x0281 }

      before do
        memory.set_byte(address, 0xff)
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    context 'with absolute,x addressing mode' do
      let(:addressing_mode) { :absolute_x }
      let(:operand) { address }
      let(:offset) { 0x0f }
      let(:address) { 0x0200 }

      before do
        memory.set_byte(address + offset, 0xff)
        subject.x = offset
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta
        expect(memory.get_byte(address + offset)).to eq(value)
      end
    end

    context 'with absolute,y addressing mode' do
      let(:addressing_mode) { :absolute_y }
      let(:operand) { address }
      let(:offset) { 0x0f }
      let(:address) { 0x0200 }

      before do
        memory.set_byte(address + offset, 0xff)
        subject.y = offset
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta
        expect(memory.get_byte(address + offset)).to eq(value)
      end
    end

    context 'with indirect,x addressing mode' do
      let(:addressing_mode) { :indirect_x }
      let(:operand) { address }
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0x55 }

      before do
        memory.set_byte(indirect_address, 0xff)
        memory.set_bytes((address + offset) & 0xff, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.x = offset
        subject.a = value
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta
        expect(memory.get_byte(indirect_address)).to eq(value)
      end

      context 'when the offset exceed page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.sta
          expect(memory.get_byte(indirect_address)).to eq(value)
        end
      end
    end

    context 'with indirect,y addressing mode' do
      let(:addressing_mode) { :indirect_y }
      let(:operand) { address }
      let(:indirect_address) { 0x034a }
      let(:address) { 0xc1 }
      let(:offset) { 2 }
      let(:value) { 0x55 }

      before do
        memory.set_byte(indirect_address + offset, 0xff)
        memory.set_bytes(address, 2, [lsb(indirect_address), msb(indirect_address)])
        subject.y = offset
        subject.a = value
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta
        expect(memory.get_byte(indirect_address + offset)).to eq(value)
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { offset }
      let(:offset) { 0xc1 }

      before do
        memory.set_byte(offset, 0xff)
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta
        expect(memory.get_byte(offset)).to eq(value)
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x00 }
      let(:offset) { 0x0f }

      before do
        memory.set_byte(offset, 0xff)
        subject.x = offset
      end

      it 'stores the accumulator value at the correct address' do
        subject.sta
        expect(memory.get_byte(offset)).to eq(value)
      end

      context 'when the offset exceeds page bounds' do
        let(:address) { 0xff }

        it 'wraps around' do
          subject.sta
          expect(memory.get_byte(offset - 1)).to eq(value)
        end
      end
    end
  end

  describe '#stx' do
    let(:value) { 0x3c }

    before do
      subject.x = value
    end

    context 'with absolute addressing mode' do
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x0283 }

      it 'stores the x-index register value at the correct address' do
        subject.stx
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xb2 }

      it 'stores the x-index register value at the correct address' do
        subject.stx
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    context 'with zero page,y addressing mode' do
      let(:addressing_mode) { :zero_page_y }
      let(:operand) { address }
      let(:address) { 0xb2 }
      let(:offset) { 5 }

      before do
        subject.y = offset
      end

      it 'stores the x-index register value at the correct address' do
        subject.stx
        expect(memory.get_byte(address + offset)).to eq(value)
      end

      context 'when the offset exceeds page bounds' do
        let(:offset) { 0xff }

        it 'wraps around' do
          subject.stx
          expect(memory.get_byte(address + offset - 0x100)).to eq(value)
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
      let(:addressing_mode) { :absolute }
      let(:operand) { address }
      let(:address) { 0x0284 }

      it 'stores the y-index register value at the correct address' do
        subject.sty
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    context 'with zero page addressing mode' do
      let(:addressing_mode) { :zero_page }
      let(:operand) { address }
      let(:address) { 0xb3 }

      it 'stores the y-index register value at the correct address' do
        subject.sty
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    context 'with zero page,x addressing mode' do
      let(:addressing_mode) { :zero_page_x }
      let(:operand) { address }
      let(:address) { 0x00 }
      let(:offset) { 0x0f }

      before do
        memory.set_byte(offset, 0xff)
        subject.x = offset
      end

      it 'stores the y-index register value at the correct address' do
        subject.sty
        expect(memory.get_byte(offset)).to eq(value)
      end

      context 'when the offset exceeds page bounds' do
        let(:address) { 0xff }

        it 'is subject to wrap-around' do
          subject.sty
          expect(memory.get_byte(offset - 1)).to eq(value)
        end
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
      subject.tax
      expect(subject.x).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tax
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tax
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tax
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tax
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
      subject.tay
      expect(subject.y).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tay
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tay
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tay
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tay
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
      subject.tsx
      expect(subject.x).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tsx
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tsx
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tsx
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tsx
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
      subject.txa
      expect(subject.a).to eq(value)
    end

    it 'sets the sign flag' do
      subject.txa
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.txa
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.txa
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.txa
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
      subject.txs
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
      subject.tya
      expect(subject.a).to eq(value)
    end

    it 'sets the sign flag' do
      subject.tya
      expect(subject.n?).to be_truthy
    end

    it 'clears the zero flag' do
      subject.tya
      expect(subject.z?).to be_falsey
    end

    context 'with a value of zero' do
      let(:value) { 0 }

      it 'clears the sign flag' do
        subject.tya
        expect(subject.n?).to be_falsey
      end

      it 'sets the zero flag' do
        subject.tya
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
end
