require 'spec_helper'

describe Vic20::Timer do
  # let(:memory) { Vic20::Memory.new([]) }
  #
  # subject { described_class.new(memory) }

  describe 'register select lines' do
    pending
  end

  describe 'port pins' do
    describe 'port a' do
      it 'can send output' do
        expect(subject.pa.value).to eq(0)
      end

      it 'can receive input' do
        subject.pa.value = 0xff
        expect(subject.pa.value).to eq(0xff)
      end

      it 'can read individual pins' do
        8.times do |pin|
          expect(subject.pa[pin]).to eq(0)
        end
      end

      it 'can write individual pins' do
        8.times do |pin|
          subject.pa[pin] = 1
          expect(subject.pa[pin]).to eq(1)
        end
      end
    end

    describe 'port b' do
      it 'can be read' do
        expect(subject.pb.value).to eq(0)
      end

      it 'can receive input' do
        subject.pb.value = 0xff
        expect(subject.pb.value).to eq(0xff)
      end

      it 'can read individual pins' do
        8.times do |pin|
          expect(subject.pa[pin]).to eq(0)
        end
      end

      it 'can write individual pins' do
        8.times do |pin|
          subject.pa[pin] = 1
          expect(subject.pa[pin]).to eq(1)
        end
      end
    end
  end

  describe 'data bus' do
    pending
  end

  describe 'chip select lines' do
    pending
  end

  describe 'read/write line' do
    pending
  end

  describe 'control lines' do
    pending
  end

  describe 'internal registers' do
    pending
  end
end
