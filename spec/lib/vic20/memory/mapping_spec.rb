require 'spec_helper'

fdescribe Vic20::Memory::Mapping do
  let(:memory) { Vic20::Memory.new([]) }
  let(:address) { 0x1000 }
  let(:register) { 7 }
  let(:value) { 13 }

  subject { described_class.new(memory, address) }

  it 'returns the value from memory' do
    memory.set_byte(address + register, value)
    expect(subject[register]).to eq(value)
  end

  it 'sets the value to memory' do
    subject[register] = value
    expect(memory.get_byte(address + register)).to eq(value)
  end
end
