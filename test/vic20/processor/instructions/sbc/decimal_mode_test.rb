# frozen_string_literal: true
require 'test_helper'

module Vic20::Processor::Instructions::SBC
  class DecimalModeTest < Vic20::Processor::Test
    def test_without_borrow
      a = 0x46
      value = 0x12

      # SED      ; Decimal mode (BCD subtraction: 46 - 12 = 34)
      # SEC
      @processor.p = Vic20::Processor::D_FLAG | Vic20::Processor::C_FLAG
      # LDA #$46
      @processor.a = a
      # SBC #$12 ; After this instruction, C = 1, A = $34)
      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.sbc

      assert_equal(0x34, @processor.a)
      assert_carry_flag
    end

    def test_without_borrow_when_negative
      a = 0x21
      value = 0x34

      # SED      ; Decimal mode (BCD subtraction: 21 - 34)
      # SEC
      @processor.p = Vic20::Processor::D_FLAG | Vic20::Processor::C_FLAG
      # LDA #$21
      @processor.a = a
      # SBC #$34 ; After this instruction, C = 0, A = $87)
      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.sbc

      assert_equal(0x87, @processor.a)
      refute_carry_flag
    end

    def test_with_borrow
      a = 0x32
      value = 0x02

      # SED      ; Decimal mode (BCD subtraction: 32 - 2 - 1 = 29)
      # CLC      ; Note: carry is clear, not set!
      @processor.p = Vic20::Processor::D_FLAG
      # LDA #$32
      @processor.a = a
      # SBC #$02 ; After this instruction, C = 1, A = $29)
      @processor.addressing_mode = :immediate
      @processor.operand = value
      @processor.sbc

      assert_equal(0x29, @processor.a)
      assert_carry_flag
    end
  end
end
