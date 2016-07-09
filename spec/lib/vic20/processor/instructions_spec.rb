require 'spec_helper'

describe Vic20::Processor do
  let(:memory) { [] }
  subject { described_class.new(memory) }

  describe '#ldx' do
    before do
      subject.x = 0x00
    end

    context 'with immediate addressing mode' do
      it 'sets the x index register' do
        value = 0xbf
        subject.ldx(:immediate, [0xa2, value])
        expect(subject.x).to eq(value)
      end
    end
  end

  describe '#sei' do
    before do
      subject.p = 0x00
    end

    it 'sets the interrupt flag' do
      subject.sei(:implied, [0x78])
      expect(subject.i?).to be_truthy
    end
  end
end
