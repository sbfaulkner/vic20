module Vic20
  class VIC
    BASE_ADDRESS = 0x9000

    BLACK        = 0
    WHITE        = 1
    RED          = 2
    CYAN         = 3
    PURPLE       = 4
    GREEN        = 5
    BLUE         = 6
    YELLOW       = 7
    ORANGE       = 8
    LIGHT_ORANGE = 9
    PINK         = 10
    LIGHT_CYAN   = 11
    LIGHT_PURPLE = 12
    LIGHT_GREEN  = 13
    LIGHT_BLUE   = 14
    LIGHT_YELLOW = 15

    def initialize(memory)
      @cr = Vic20::Memory::Mapping.new(memory, BASE_ADDRESS)
    end

    attr_reader :cr
  end
end
