require 'spec_helper'

describe Vic20::VIC do
  let(:memory) { Vic20::Memory.new }

  subject { described_class.new(memory) }

  describe 'registers' do
    # CR0: $9000 - decimal 36864. Usual value decimal 12.
    # A dual function register.
    # Function 1: Bit 7 selects insterface scan mode for the TV.
    # Function 2: Bits 0-6 determine the distance from the left hand side of the
    #             TV picture to the first column of characters.
    #  Note: On most modern TV sets the effect of selecting the interface scan mode
    #  is to produce a light rippling on the screen.
    describe 'CR0' do
      let(:address) { 0x9000 }
      let(:register) { 0 }
      let(:default) { 12 }
      let(:value) { 13 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR1: $9001 - decimal 36865. Usual value decimal 38.
    # A single function register.
    # All the bits of this register are used to determine the distance from the
    # top of the TV picture to the first line of characters.
    describe 'CR1' do
      let(:address) { 0x9001 }
      let(:register) { 1 }
      let(:default) { 38 }
      let(:value) { 37 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR2: $9002 - decimal 36866. Usual value decimal 150.
    # A dual function register.
    # The first seven bits fo this register determine the number of columns in
    # the TV display. Normally this will be the expected value of 22.
    # Bit 7 of this register is used to hold the value for line 9 of the address
    # for the video RAM. On an unexpanded VIC 20 as the address of the Video
    # RAM is $1E00 and therefore this bit 7 is set, however when the video RAM is
    # moved to $1000 then bit 7 becomes reset.
    describe 'CR2' do
      let(:address) { 0x9002 }
      let(:register) { 2 }
      let(:default) { 150 }
      let(:value) { 22 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR3: $9003 - decimal 36867. Usual value 174.
    # A triple function register.
    # Bit 7 holds the lowest bit of TV raster counter and is therefore alternately
    # set and reset.
    # Bits 1-6 of this register determine the number of rows in the TV display.
    # The value of these bits will normally be 23.
    # Bit 0 is very special as it controls whether normal sized characters or
    # double sized characters are to be displayed. The normal size for a character
    # is 8*8 pixels and is slected by bit 0 being reset, however double sized
    # characters, 16*8 pixels, can be selected by having this bit set.
    #  The facility for being able to use double sized characters is not very
    # useful on an unexpanded VIC 20 as there is insufficient RAM to define a
    # reasonable number of double sized characters.
    describe 'CR3' do
      let(:address) { 0x9003 }
      let(:register) { 3 }
      let(:default) { 174 }
      let(:value) { 151 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR4: $9004 - 36868. No usual value.
    #  This register, together with bit 7 of CR3, forms the TV raster counter. On
    #  a 625 line TV this register will count between 0 and 255, and the whole
    #  counter between 0 and 311.
    #  Emulation note: some programs check this byte and don't continue until it
    #  reaches a certain value. For this reason make sure that this location is
    #  counting up all the time.
    describe 'CR4' do
      let(:address) { 0x9004 }
      let(:register) { 4 }
      let(:default) { 0 }
      let(:value) { 255 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR5: $9005 - 36869. Usual value 240.
    # A dual function register.
    # Bits 4-7 holds the values of the topmost four address lines for the Video
    # RAM and bits 0-3 the corresponding values for the character table.
    # Of all these values bits 0 & 7 have a special significance, as whenver
    # this bit is set the memory slected will be in 'block 0', i.e. from $0000-
    # $1FFF, and when reset in 'block 4', i.e. from $8000-$9FFF.
    # In normal operation of a VIC20 this register holds the value 240 decimal
    # and this leads to the Video RAM being situated at $1E00 and the character
    # table at $8000. These addresses are found as follows:
    #
    # Video RAM - bit 7 is set, thereby addressing 'block 0'.
    # -Address lines A12, A11, A10, and A9 are all set and the full address is
    # $1E00 as A13, A14, and A15 are reset for 'block 0'.
    #
    # Character table - bit 3 is reset, thereby addressing 'block 4'.
    # -Address lines A12, A11 and A10 are all reset and the full address is
    # $8000 as A15 is set and A13 and A14 are reset for 'block 4'.
    describe 'CR5' do
      let(:address) { 0x9005 }
      let(:register) { 5 }
      let(:default) { 240 }
      let(:value) { 15 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR6: $9006 - 36870. Usual value 0.
    # This register is used in conjunction with the light pen and holds the
    # horizontal postion.
    describe 'CR6' do
      let(:address) { 0x9006 }
      let(:register) { 6 }
      let(:default) { 0 }
      let(:value) { 0x7f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR7: $9007 - 36871. Usual value 1.
    # The vertical position of the light pen.
    describe 'CR7' do
      let(:address) { 0x9007 }
      let(:register) { 7 }
      let(:default) { 0 }
      let(:value) { 0x7f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR8: $9008 - 36872. Usual value 255.
    # The counter for potentiometer 1.
    describe 'CR8' do
      let(:address) { 0x9008 }
      let(:register) { 8 }
      let(:default) { 255 }
      let(:value) { 0x7f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CR9: $9009 - 36873. Usual value 255.
    # The counter for potentiometer 2.
    describe 'CR9' do
      let(:address) { 0x9009 }
      let(:register) { 9 }
      let(:default) { 255 }
      let(:value) { 0x7f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CRA: $900A - 36874. Usual value 0.
    # This register controls 'speaker-1'. Bit 7 is the on/off control bit, whilst
    # bits 0-6 select the actual note. Speaker 1 has an alto voice.
    describe 'CRA' do
      let(:address) { 0x900A }
      let(:register) { 10 }
      let(:default) { 0 }
      let(:value) { 0x80 + 0x3f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CRB: $900B - 36875. Usual value 0.
    # This register controls 'speaker-2', the tenor voice.
    describe 'CRB' do
      let(:address) { 0x900B }
      let(:register) { 11 }
      let(:default) { 0 }
      let(:value) { 0x80 + 0x3f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CRC: $900C - 36876. Usual value 0.
    # This register controls 'speaker-3', the soprano voice.
    describe 'CRC' do
      let(:address) { 0x900C }
      let(:register) { 12 }
      let(:default) { 0 }
      let(:value) { 0x80 + 0x3f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CRD: $900D - 36877. Usual value 0.
    # This register controls 'speaker-4', the noise voice.
    describe 'CRD' do
      let(:address) { 0x900D }
      let(:register) { 13 }
      let(:default) { 0 }
      let(:value) { 0x80 + 0x3f }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CRE: $900E - 36878. Usual value 0.
    # A dual purpose register.
    # Bits 0-3 form the counter for the volume control of the four speakers.
    # When all the bits are reset the volume control is off and when all the bits
    # are set the volume control is fully on.
    # Bits 4-7 hold the users slection of the auxiliary colour which is only used
    # when multicolour is switched on (discussed later).
    describe 'CRE' do
      let(:address) { 0x900e }
      let(:register) { 14 }
      let(:default) { 0 }
      let(:value) { 15 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end

    # CRF: $900F - 36879. Usual value 27.
    # This is the main colour selecting register of the VIC and has three distinct
    # functions.
    # Bits 0-2 are used to hold the border colour. In the VIC 20 there are eight
    # colours that can be border colours and these are:
    #
    #    0 - 000   Black
    #    1 - 001   White
    #    2 - 010   Red
    #    3 - 011   Cyan
    #    4 - 100   Purple
    #    5 - 101   Green
    #    6 - 110   Blue
    #    7 - 111   Yellow
    #
    # These border colours can be selected by putting the required value into the
    # bits 0-2 of control register CRF.
    # Bit 3 is the reverse field control bit. At any time the state of this bit
    # can be changed to reverse the whole display.
    # Bits 4-7 hold the background colour for the display. There are 16 possible
    # colours and the following tble fives the colours together with their codes.
    # Note that these codes are the same for the auxiliary colours as used in the
    # multicolour mode.
    #
    #    0 - 0000   Black
    #    1 - 0001   White
    #    2 - 0010   Red
    #    3 - 0011   Cyan
    #    4 - 0100   Purple
    #    5 - 0101   Green
    #    6 - 0110   Blue
    #    7 - 0111   Yellow
    #    8 - 1000   Orange
    #    9 - 1001   Light orange
    #   10 - 1010   Pink
    #   11 - 1011   Light cyan
    #   12 - 1100   Light purple
    #   13 - 1101   Light green
    #   14 - 1110   Light blue
    #   15 - 1111   Light yellow
    describe 'CRF' do
      let(:address) { 0x900F }
      let(:register) { 15 }
      let(:default) { 27 }
      let(:value) { 97 }

      it 'returns the value from memory' do
        memory.set_byte(address, default)
        expect(subject.cr[register]).to eq(default)
      end

      it 'sets the value to memory' do
        subject.cr[register] = value
        expect(memory.get_byte(address)).to eq(value)
      end
    end
  end
end
