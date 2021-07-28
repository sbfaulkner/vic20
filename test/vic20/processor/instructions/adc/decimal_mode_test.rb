# frozen_string_literal: true
require 'test_helper'

module Vic20
  class Processor
    module Instructions
      module ADC
        class DecimalModeTest < Vic20::Processor::Test
          def test_carry_flag_clear
            a = 0x12
            value = 0x34

            # SED      ; Decimal mode (BCD addition: 12 + 34 = 46)
            # CLC
            @processor.p = Vic20::Processor::D_FLAG
            # LDA #$12
            @processor.a = a
            # ADC #$34 ; After this instruction, C = 0, A = $46
            @processor.addressing_mode = :immediate
            @processor.operand = value
            @processor.adc

            assert_equal(0x46, @processor.a)

            refute_carry_flag
          end

          def test_carry_flag_set_when_result_greater_than_99
            a = 0x81
            value = 0x92

            # SED      ; Decimal mode (BCD addition: 81 + 92 = 173)
            # CLC
            @processor.p = Vic20::Processor::D_FLAG
            # LDA #$81
            @processor.a = a
            # ADC #$92 ; After this instruction, C = 1, A = $73
            @processor.addressing_mode = :immediate
            @processor.operand = value
            @processor.adc

            assert_equal(0x73, @processor.a)

            assert_carry_flag
          end

          def test_carry
            a = 0x58
            value = 0x46

            # SED      ; Decimal mode (BCD addition: 58 + 46 + 1 = 105)
            @processor.p = Vic20::Processor::D_FLAG
            # SEC      ; Note: carry is set, not clear!
            @processor.p |= Vic20::Processor::C_FLAG
            # LDA #$58
            @processor.a = a
            # ADC #$46 ; After this instruction, C = 1, A = $05
            @processor.addressing_mode = :immediate
            @processor.operand = value
            @processor.adc

            assert_equal(0x05, @processor.a)

            assert_carry_flag
          end
        end
      end
    end
  end
end
