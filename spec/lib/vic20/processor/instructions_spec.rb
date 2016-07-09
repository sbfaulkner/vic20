require 'spec_helper'

describe Vic20::Processor do
  let(:memory) { [] }
  subject { described_class.new(memory) }

  describe '#ldx' do
    context 'with immediate addressing mode' do
      it 'sets the x index register' do
        value = 0xbf
        subject.ldx(:immediate, [0xa2, value])
        expect(subject.x).to eq(value)
      end
    end
  end
end
