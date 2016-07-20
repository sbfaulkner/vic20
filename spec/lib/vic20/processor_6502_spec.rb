require 'spec_helper'

describe Vic20::Processor do
  let(:firmware) { File.expand_path('../../../firmware/6502_functional_test.bin', __dir__) }
  let(:memory) { Vic20::Memory.new(firmware) }
  subject { Vic20::Processor.new(memory) }

  before do
    Vic20::Processor.prepend Vic20::Processor::Halt
    subject.reset(0x0400)
  end

  it 'runs the test successfully' do
    expect { subject.run }.to raise_exception(Vic20::Processor::Trap, /Execution halted @ \$3399/)
  end
end
