require 'spec_helper'

describe Vic20::NMOS6502::Register do
  it 'is a register' do
    expect(subject).to be_a(Vic20::NMOS6502::Register)
  end
end
