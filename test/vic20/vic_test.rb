# frozen_string_literal: true
require 'test_helper'

module Vic20
  class VICTest < Minitest::Test
    def setup
      super

      @memory = Vic20::Memory.new
      @vic = Vic20::VIC.new(@memory)
    end

    # CR0: $9000 - decimal 36864. Usual value decimal 12.
    # A dual function register.
    # Function 1: Bit 7 selects insterface scan mode for the TV.
    # Function 2: Bits 0-6 determine the distance from the left hand side of the
    #             TV picture to the first column of characters.
    #  Note: On most modern TV sets the effect of selecting the interface scan mode
    #  is to produce a light rippling on the screen.
    def test_cr0_returns_value_from_memory
      @memory.set_byte(0x9000, 12)
      assert_equal(12, @vic.cr[0])
    end

    def test_cr0_sets_value_to_memory
      @vic.cr[0] = 13
      assert_equal(13, @memory.get_byte(0x9000))
    end

    # CR1: $9001 - decimal 36865. Usual value decimal 38.
    # A single function register.
    # All the bits of this register are used to determine the distance from the
    # top of the TV picture to the first line of characters.
    def test_cr1_returns_value_from_memory
      @memory.set_byte(0x9001, 38)
      assert_equal(38, @vic.cr[1])
    end

    def test_cr1_sets_value_to_memory
      @vic.cr[1] = 37
      assert_equal(37, @memory.get_byte(0x9001))
    end

    # CR2: $9002 - decimal 36866. Usual value decimal 150.
    # A dual function register.
    # The first seven bits fo this register determine the number of columns in
    # the TV display. Normally this will be the expected value of 22.
    # Bit 7 of this register is used to hold the value for line 9 of the address
    # for the video RAM. On an unexpanded VIC 20 as the address of the Video
    # RAM is $1E00 and therefore this bit 7 is set, however when the video RAM is
    # moved to $1000 then bit 7 becomes reset.
    def test_cr2_returns_value_from_memory
      @memory.set_byte(0x9002, 150)
      assert_equal(150, @vic.cr[2])
    end

    def test_cr2_sets_value_to_memory
      @vic.cr[2] = 22
      assert_equal(22, @memory.get_byte(0x9002))
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
    def test_cr3_returns_value_from_memory
      @memory.set_byte(0x9003, 174)
      assert_equal(174, @vic.cr[3])
    end

    def test_cr3_sets_value_to_memory
      @vic.cr[3] = 151
      assert_equal(151, @memory.get_byte(0x9003))
    end

    # CR4: $9004 - 36868. No usual value.
    #  This register, together with bit 7 of CR3, forms the TV raster counter. On
    #  a 625 line TV this register will count between 0 and 255, and the whole
    #  counter between 0 and 311.
    #  Emulation note: some programs check this byte and don't continue until it
    #  reaches a certain value. For this reason make sure that this location is
    #  counting up all the time.
    def test_cr4_returns_value_from_memory
      @memory.set_byte(0x9004, 0)
      assert_equal(0, @vic.cr[4])
    end

    def test_cr4_sets_value_to_memory
      @vic.cr[4] = 255
      assert_equal(255, @memory.get_byte(0x9004))
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
    def test_cr5_returns_value_from_memory
      @memory.set_byte(0x9005, 240)
      assert_equal(240, @vic.cr[5])
    end

    def test_cr5_sets_value_to_memory
      @vic.cr[5] = 15
      assert_equal(15, @memory.get_byte(0x9005))
    end

    # CR6: $9006 - 36870. Usual value 0.
    # This register is used in conjunction with the light pen and holds the
    # horizontal postion.
    def test_cr6_returns_value_from_memory
      @memory.set_byte(0x9006, 0)
      assert_equal(0, @vic.cr[6])
    end

    def test_cr6_sets_value_to_memory
      @vic.cr[6] = 0x7f
      assert_equal(0x7f, @memory.get_byte(0x9006))
    end

    # CR7: $9007 - 36871. Usual value 1.
    # The vertical position of the light pen.
    def test_cr7_returns_value_from_memory
      @memory.set_byte(0x9007, 0)
      assert_equal(0, @vic.cr[7])
    end

    def test_cr7_sets_value_to_memory
      @vic.cr[7] = 0x7f
      assert_equal(0x7f, @memory.get_byte(0x9007))
    end

    # CR8: $9008 - 36872. Usual value 255.
    # The counter for potentiometer 1.
    def test_cr8_returns_value_from_memory
      @memory.set_byte(0x9008, 255)
      assert_equal(255, @vic.cr[8])
    end

    def test_cr8_sets_value_to_memory
      @vic.cr[8] = 0x7f
      assert_equal(0x7f, @memory.get_byte(0x9008))
    end

    # CR9: $9009 - 36873. Usual value 255.
    # The counter for potentiometer 2.
    def test_cr9_returns_value_from_memory
      @memory.set_byte(0x9009, 255)
      assert_equal(255, @vic.cr[9])
    end

    def test_cr9_sets_value_to_memory
      @vic.cr[9] = 0x7f
      assert_equal(0x7f, @memory.get_byte(0x9009))
    end

    # CRA: $900A - 36874. Usual value 0.
    # This register controls 'speaker-1'. Bit 7 is the on/off control bit, whilst
    # bits 0-6 select the actual note. Speaker 1 has an alto voice.
    def test_cra_returns_value_from_memory
      @memory.set_byte(0x900A, 0)
      assert_equal(0, @vic.cr[10])
    end

    def test_cra_sets_value_to_memory
      @vic.cr[10] = 0x80 + 0x3f
      assert_equal(0x80 + 0x3f, @memory.get_byte(0x900A))
    end

    # CRB: $900B - 36875. Usual value 0.
    # This register controls 'speaker-2', the tenor voice.
    def test_crb_returns_value_from_memory
      @memory.set_byte(0x900B, 0)
      assert_equal(0, @vic.cr[11])
    end

    def test_crb_sets_value_to_memory
      @vic.cr[11] = 0x80 + 0x3f
      assert_equal(0x80 + 0x3f, @memory.get_byte(0x900B))
    end

    # CRC: $900C - 36876. Usual value 0.
    # This register controls 'speaker-3', the soprano voice.
    def test_crc_returns_value_from_memory
      @memory.set_byte(0x900C, 0)
      assert_equal(0, @vic.cr[12])
    end

    def test_crc_sets_value_to_memory
      @vic.cr[12] = 0x80 + 0x3f
      assert_equal(0x80 + 0x3f, @memory.get_byte(0x900C))
    end

    # CRD: $900D - 36877. Usual value 0.
    # This register controls 'speaker-4', the noise voice.
    def test_crd_returns_value_from_memory
      @memory.set_byte(0x900D, 0)
      assert_equal(0, @vic.cr[13])
    end

    def test_crd_sets_value_to_memory
      @vic.cr[13] = 0x80 + 0x3f
      assert_equal(0x80 + 0x3f, @memory.get_byte(0x900D))
    end

    # CRE: $900E - 36878. Usual value 0.
    # A dual purpose register.
    # Bits 0-3 form the counter for the volume control of the four speakers.
    # When all the bits are reset the volume control is off and when all the bits
    # are set the volume control is fully on.
    # Bits 4-7 hold the users slection of the auxiliary colour which is only used
    # when multicolour is switched on (discussed later).
    def test_cre_returns_value_from_memory
      @memory.set_byte(0x900E, 0)
      assert_equal(0, @vic.cr[14])
    end

    def test_cre_sets_value_to_memory
      @vic.cr[14] = 15
      assert_equal(15, @memory.get_byte(0x900E))
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
    def test_crf_returns_value_from_memory
      @memory.set_byte(0x900F, 27)
      assert_equal(27, @vic.cr[15])
    end

    def test_crf_sets_value_to_memory
      @vic.cr[15] = 97
      assert_equal(97, @memory.get_byte(0x900F))
    end
  end
end
