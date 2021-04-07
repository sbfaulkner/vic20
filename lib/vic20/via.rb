# frozen_string_literal: true
module Vic20
  class VIA
    ORB              = 0
    IRB              = 0
    ORA              = 1
    IRA              = 1
    DDRB             = 2
    DDRA             = 3
    T1C_L            = 4
    T1C_H            = 5
    T1L_L            = 6
    T1L_H            = 7
    T2C_L            = 8
    T2C_H            = 9
    SR               = 10
    ACR              = 11
    PCR              = 12
    IFR              = 13
    IER              = 14
    ORA_NO_HANDSHAKE = 15
    IRA_NO_HANDSHAKE = 15

    # class Register
    #   def initialize
    #     @value = 0
    #   end
    #
    #   attr_accessor :value
    #
    #   def [](bit)
    #     @value[bit]
    #   end
    #
    #   def []=(bit, value)
    #     @value &= ~(1 << bit)
    #     @value |= (value << bit)
    #     value
    #   end
    # end

    def initialize(memory, address)
      @ir = Vic20::Memory::Mapping.new(memory, address)
      # @pa = Register.new
      # @pb = Register.new
    end

    # attr_reader :pa, :pb
    attr_reader :ir
  end
end
