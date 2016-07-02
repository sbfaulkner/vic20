module Vic20
  class Register < SimpleDelegator
    attr_accessor :value

    def initialize(value = 0)
      self.value = value

      super(self.value)
    end
  end
end
