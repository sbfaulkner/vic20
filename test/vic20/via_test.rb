# frozen_string_literal: true
require 'test_helper'

module Vic20
  class VIATest < Minitest::Test
    def setup
      super

      @memory = Vic20::Memory.new
      @via = Vic20::VIA.new(@memory, 0x9110)
    end

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
    def test_orb_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::ORB, 0x75)
      assert_equal(0x75, @via.ir[Vic20::VIA::ORB])
    end

    def test_irb_sets_the_value_to_memory
      @via.ir[Vic20::VIA::IRB] = 0x8a
      assert_equal(0x8a, @memory.get_byte(0x9110 + Vic20::VIA::IRB))
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
    def test_ora_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::ORA, 0x8a)
      assert_equal(0x8a, @via.ir[Vic20::VIA::ORA])
    end

    def test_ira_sets_the_value_to_memory
      @via.ir[Vic20::VIA::IRA] = 0x75
      assert_equal(0x75, @memory.get_byte(0x9110 + Vic20::VIA::IRA))
    end

    # 9112       37138  Data direction register B
    def test_ddrb_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::DDRB, 0x85)
      assert_equal(0x85, @via.ir[Vic20::VIA::DDRB])
    end

    def test_ddrb_sets_the_value_to_memory
      @via.ir[Vic20::VIA::DDRB] = 0x7a
      assert_equal(0x7a, @memory.get_byte(0x9110 + Vic20::VIA::DDRB))
    end

    # 9113       37139  Data direction register A
    def test_ddra_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::DDRA, 0xa7)
      assert_equal(0xa7, @via.ir[Vic20::VIA::DDRA])
    end

    def test_ddra_sets_the_value_to_memory
      @via.ir[Vic20::VIA::DDRA] = 0x58
      assert_equal(0x58, @memory.get_byte(0x9110 + Vic20::VIA::DDRA))
    end

    # 9114       37140  Timer 1 low byte
    def test_t1c_l_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::T1C_L, 0x1f)
      assert_equal(0x1f, @via.ir[Vic20::VIA::T1C_L])
    end

    def test_t1c_l_sets_the_value_to_memory
      @via.ir[Vic20::VIA::T1C_L] = 0xe0
      assert_equal(0xe0, @memory.get_byte(0x9110 + Vic20::VIA::T1C_L))
    end

    # 9115       37141  Timer 1 high byte & counter
    def test_t1c_h_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::T1C_H, 0x1e)
      assert_equal(0x1e, @via.ir[Vic20::VIA::T1C_H])
    end

    def test_t1c_h_sets_the_value_to_memory
      @via.ir[Vic20::VIA::T1C_H] = 0xe1
      assert_equal(0xe1, @memory.get_byte(0x9110 + Vic20::VIA::T1C_H))
    end

    # 9116       37142  Timer 1 low byte
    def test_t1l_l_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::T1L_L, 0xf0)
      assert_equal(0xf0, @via.ir[Vic20::VIA::T1L_L])
    end

    def test_t1l_l_sets_the_value_to_memory
      @via.ir[Vic20::VIA::T1L_L] = 0x0f
      assert_equal(0x0f, @memory.get_byte(0x9110 + Vic20::VIA::T1L_L))
    end

    # 9117       37143  Timer 1 high byte
    def test_t1l_h_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::T1L_H, 0x11)
      assert_equal(0x11, @via.ir[Vic20::VIA::T1L_H])
    end

    def test_t1l_h_sets_the_value_to_memory
      @via.ir[Vic20::VIA::T1L_H] = 0xee
      assert_equal(0xee, @memory.get_byte(0x9110 + Vic20::VIA::T1L_H))
    end

    # 9118       37144  Timer 2 low byte
    def test_t2c_l_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::T2C_L, 0xd5)
      assert_equal(0xd5, @via.ir[Vic20::VIA::T2C_L])
    end

    def test_t2c_l_sets_the_value_to_memory
      @via.ir[Vic20::VIA::T2C_L] = 0x2a
      assert_equal(0x2a, @memory.get_byte(0x9110 + Vic20::VIA::T2C_L))
    end

    # 9119       37145  Timer 2 high byte
    def test_t2c_h_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::T2C_H, 0x25)
      assert_equal(0x25, @via.ir[Vic20::VIA::T2C_H])
    end

    def test_t2c_h_sets_the_value_to_memory
      @via.ir[Vic20::VIA::T2C_H] = 0xda
      assert_equal(0xda, @memory.get_byte(0x9110 + Vic20::VIA::T2C_H))
    end

    # 911A       37146  Shift register
    def test_sr_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::SR, 0xa5)
      assert_equal(0xa5, @via.ir[Vic20::VIA::SR])
    end

    def test_sr_sets_the_value_to_memory
      @via.ir[Vic20::VIA::SR] = 0x5a
      assert_equal(0x5a, @memory.get_byte(0x9110 + Vic20::VIA::SR))
    end

    # 911B       37147  Auxiliary control register
    def test_acr_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::ACR, 0x78)
      assert_equal(0x78, @via.ir[Vic20::VIA::ACR])
    end

    def test_acr_sets_the_value_to_memory
      @via.ir[Vic20::VIA::ACR] = 0x87
      assert_equal(0x87, @memory.get_byte(0x9110 + Vic20::VIA::ACR))
    end

    # 911C       37148  Peripheral control register
    #                   (CA1, CA2, CB1, CB2)
    #                   CA1 = restore key (Bit 0)
    #                   CA2 = cassette motor control (Bits 1-3)
    #                   CB1 = interrupt signal for received
    #                       RS-232 data (Bit 4)
    #                   CB2=transmitted RS-232 data (Bits
    #                       5-7)
    def test_pcr_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::PCR, 0x39)
      assert_equal(0x39, @via.ir[Vic20::VIA::PCR])
    end

    def test_pcr_sets_the_value_to_memory
      @via.ir[Vic20::VIA::PCR] = 0xc6
      assert_equal(0xc6, @memory.get_byte(0x9110 + Vic20::VIA::PCR))
    end

    # 911D       37149  Interrupt flag register
    def test_ifr_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::IFR, 0x36)
      assert_equal(0x36, @via.ir[Vic20::VIA::IFR])
    end

    def test_ifr_sets_the_value_to_memory
      @via.ir[Vic20::VIA::IFR] = 0xc9
      assert_equal(0xc9, @memory.get_byte(0x9110 + Vic20::VIA::IFR))
    end

    # 911E       37150  Interrupt enable register
    def test_ier_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::IER, 0xc6)
      assert_equal(0xc6, @via.ir[Vic20::VIA::IER])
    end

    def test_ier_sets_the_value_to_memory
      @via.ir[Vic20::VIA::IER] = 0x39
      assert_equal(0x39, @memory.get_byte(0x9110 + Vic20::VIA::IER))
    end

    # 911F       37151  Port A (Sense cassette switch)
    def ora_no_handshake_returns_the_value_from_memory
      @memory.set_byte(0x9110 + Vic20::VIA::ORA_NO_HANDSHAKE, 0x8a)
      assert_equal(0x8a, @via.ir[Vic20::VIA::ORA_NO_HANDSHAKE])
    end

    def ira_no_handshake_sets_the_value_to_memory
      @via.ir[Vic20::VIA::IRA_NO_HANDSHAKE] = 0x75
      assert_equal(0x75, @memory.get_byte(0x9110 + Vic20::VIA::IRA_NO_HANDSHAKE))
    end
  end
end
