require 'spec_helper'

describe Vic20::VIA do
  let(:memory) { Vic20::Memory.new([]) }
  let(:address) { 0x9110 }

  subject { described_class.new(memory, address) }

  describe 'internal registers' do
    # 9110       37136  Port B output register
    #                   (user port and RS-232 lines)
    #            PIN    6522 DESCRIPTION         EIA   ABV
    #            ID     ID
    #
    #            C      PB0 Received data       (BB)  Sin
    #            D      PB1 Request to Send     (CA)  RTS
    #            E      PB2 Data terminal ready (CD)  DTR
    #            F      PB3 Ring indicator      (CE)  RI
    #            H      PB4 Received line signal (CF)  DCD
    #            J      PB5 Unassigned          ( )   XXX
    #            K      PB6 Clear to send       (CB)  CTS
    #            L      PB7 Data set ready      (CC)  DSR
    #            B      CB1 Interrupt for Sin   (BB)  Sin
    #            M      CB2 Transmitted data    (BA)  Sout
    #
    #            A      GND Protective ground   (M)   GND
    #            N      GND Signal ground       (AB)  GND
    describe 'ORB/IRB' do
      it 'returns the value from memory' do
        output = 0x75
        memory.set_byte(address + Vic20::VIA::ORB, output)
        expect(subject.ir[Vic20::VIA::ORB]).to eq(output)
      end

      it 'sets the value to memory' do
        input = 0x8a
        subject.ir[Vic20::VIA::IRB] = input
        expect(memory.get_byte(address + Vic20::VIA::IRB)).to eq(input)
      end
    end

    # 9111       37137  Port A output register
    #                    (PA0) Bit 0=Serial CLK IN
    #                    (PA1) Bit 1=Serial DATA IN
    #                    (PA2) Bit 2=Joy 0
    #                    (PA3) Bit 3=Joy 1
    #                    (PA4) Bit 4=Joy 2
    #                    (PA5) Bit 5 = Lightpen/Fire button
    #                    (PA6) Bit 6=Cassette switch sense
    #                    (PA7) Bit 7=Serial ATN out
    describe 'ORA/IRA' do
      it 'returns the value from memory' do
        output = 0x8a
        memory.set_byte(address + Vic20::VIA::ORA, output)
        expect(subject.ir[Vic20::VIA::ORA]).to eq(output)
      end

      it 'sets the value to memory' do
        input = 0x75
        subject.ir[Vic20::VIA::IRA] = input
        expect(memory.get_byte(address + Vic20::VIA::IRA)).to eq(input)
      end
    end

    # 9112       37138  Data direction register B
    describe 'DDRB' do
      it 'returns the value from memory' do
        value = 0x85
        memory.set_byte(address + Vic20::VIA::DDRB, value)
        expect(subject.ir[Vic20::VIA::DDRB]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0x7a
        subject.ir[Vic20::VIA::DDRB] = value
        expect(memory.get_byte(address + Vic20::VIA::DDRB)).to eq(value)
      end
    end

    # 9113       37139  Data direction register A
    describe 'DDRA' do
      it 'returns the value from memory' do
        value = 0xa7
        memory.set_byte(address + Vic20::VIA::DDRA, value)
        expect(subject.ir[Vic20::VIA::DDRA]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0x58
        subject.ir[Vic20::VIA::DDRA] = value
        expect(memory.get_byte(address + Vic20::VIA::DDRA)).to eq(value)
      end
    end

    # 9114       37140  Timer 1 low byte
    describe 'T1C-L' do
      it 'returns the value from memory' do
        value = 0x1f
        memory.set_byte(address + Vic20::VIA::T1C_L, value)
        expect(subject.ir[Vic20::VIA::T1C_L]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0xe0
        subject.ir[Vic20::VIA::T1C_L] = value
        expect(memory.get_byte(address + Vic20::VIA::T1C_L)).to eq(value)
      end
    end

    # 9115       37141  Timer 1 high byte & counter
    describe 'T1C-H' do
      it 'returns the value from memory' do
        value = 0x1e
        memory.set_byte(address + Vic20::VIA::T1C_H, value)
        expect(subject.ir[Vic20::VIA::T1C_H]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0xe1
        subject.ir[Vic20::VIA::T1C_H] = value
        expect(memory.get_byte(address + Vic20::VIA::T1C_H)).to eq(value)
      end
    end

    # 9116       37142  Timer 1 low byte
    describe 'T1L-L' do
      it 'returns the value from memory' do
        value = 0xf0
        memory.set_byte(address + Vic20::VIA::T1L_L, value)
        expect(subject.ir[Vic20::VIA::T1L_L]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0x0f
        subject.ir[Vic20::VIA::T1L_L] = value
        expect(memory.get_byte(address + Vic20::VIA::T1L_L)).to eq(value)
      end
    end

    # 9117       37143  Timer 1 high byte
    describe 'T1L-H' do
      it 'returns the value from memory' do
        value = 0x11
        memory.set_byte(address + Vic20::VIA::T1L_H, value)
        expect(subject.ir[Vic20::VIA::T1L_H]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0xee
        subject.ir[Vic20::VIA::T1L_H] = value
        expect(memory.get_byte(address + Vic20::VIA::T1L_H)).to eq(value)
      end
    end

    # 9118       37144  Timer 2 low byte
    describe 'T2C-L' do
      it 'returns the value from memory' do
        value = 0xd5
        memory.set_byte(address + Vic20::VIA::T2C_L, value)
        expect(subject.ir[Vic20::VIA::T2C_L]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0x2a
        subject.ir[Vic20::VIA::T2C_L] = value
        expect(memory.get_byte(address + Vic20::VIA::T2C_L)).to eq(value)
      end
    end

    # 9119       37145  Timer 2 high byte
    describe 'T2C-H' do
      it 'returns the value from memory' do
        value = 0x25
        memory.set_byte(address + Vic20::VIA::T2C_H, value)
        expect(subject.ir[Vic20::VIA::T2C_H]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0xda
        subject.ir[Vic20::VIA::T2C_H] = value
        expect(memory.get_byte(address + Vic20::VIA::T2C_H)).to eq(value)
      end
    end

    # 911A       37146  Shift register
    describe 'SR' do
      it 'returns the value from memory' do
        value = 0xa5
        memory.set_byte(address + Vic20::VIA::SR, value)
        expect(subject.ir[Vic20::VIA::SR]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0x5a
        subject.ir[Vic20::VIA::SR] = value
        expect(memory.get_byte(address + Vic20::VIA::SR)).to eq(value)
      end
    end

    # 911B       37147  Auxiliary control register
    describe 'ACR' do
      it 'returns the value from memory' do
        value = 0x78
        memory.set_byte(address + Vic20::VIA::ACR, value)
        expect(subject.ir[Vic20::VIA::ACR]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0x87
        subject.ir[Vic20::VIA::ACR] = value
        expect(memory.get_byte(address + Vic20::VIA::ACR)).to eq(value)
      end
    end

    # 911C       37148  Peripheral control register
    #                   (CA1, CA2, CB1, CB2)
    #                   CA1 = restore key (Bit 0)
    #                   CA2 = cassette motor control (Bits 1-3)
    #                   CB1 = interrupt signal for received
    #                       RS-232 data (Bit 4)
    #                   CB2=transmitted RS-232 data (Bits
    #                       5-7)
    describe 'PCR' do
      it 'returns the value from memory' do
        value = 0x39
        memory.set_byte(address + Vic20::VIA::PCR, value)
        expect(subject.ir[Vic20::VIA::PCR]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0xc6
        subject.ir[Vic20::VIA::PCR] = value
        expect(memory.get_byte(address + Vic20::VIA::PCR)).to eq(value)
      end
    end

    # 911D       37149  Interrupt flag register
    describe 'IFR' do
      it 'returns the value from memory' do
        value = 0x36
        memory.set_byte(address + Vic20::VIA::IFR, value)
        expect(subject.ir[Vic20::VIA::IFR]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0xc9
        subject.ir[Vic20::VIA::IFR] = value
        expect(memory.get_byte(address + Vic20::VIA::IFR)).to eq(value)
      end
    end

    # 911E       37150  Interrupt enable register
    describe 'IER' do
      it 'returns the value from memory' do
        value = 0xc6
        memory.set_byte(address + Vic20::VIA::IER, value)
        expect(subject.ir[Vic20::VIA::IER]).to eq(value)
      end

      it 'sets the value to memory' do
        value = 0x39
        subject.ir[Vic20::VIA::IER] = value
        expect(memory.get_byte(address + Vic20::VIA::IER)).to eq(value)
      end
    end

    # 911F       37151  Port A (Sense cassette switch)
    describe 'ORA/IRA (no handshake)' do
      it 'returns the value from memory' do
        output = 0x8a
        memory.set_byte(address + Vic20::VIA::ORA_NO_HANDSHAKE, output)
        expect(subject.ir[Vic20::VIA::ORA_NO_HANDSHAKE]).to eq(output)
      end

      it 'sets the value to memory' do
        input = 0x75
        subject.ir[Vic20::VIA::IRA_NO_HANDSHAKE] = input
        expect(memory.get_byte(address + Vic20::VIA::IRA_NO_HANDSHAKE)).to eq(input)
      end
    end
  end
end
