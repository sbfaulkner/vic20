require 'spec_helper'

require 'ipc/semaphore' # TODO: remove explicit require in spec

describe IPC::Semaphore do
  let(:count)   { 3 }
  let(:options) { { count: count } }

  subject { described_class.new(**options) }

  context 'using defaults' do
    let(:options) { {} }

    it 'creates a single semphore' do
      expect(subject.count).to eq(1)
    end
  end

  it 'creates 3 semaphores' do
    expect(subject.count).to eq(count)
  end

  describe '#get' do
    it 'returns 0' do
      expect(subject.get(0)).to eq(0)
    end
  end

  describe '#set=' do
    it 'assigns 7' do
      subject.set(2, 7)
      expect(subject.get(2)).to eq(7)
    end
  end

  describe 'a proxied semaphore' do
    let(:semaphore) { subject[0] }

    describe '#value' do
      it 'returns 0' do
        expect(semaphore.value).to eq(0)
      end
    end

    describe '#value=' do
      it 'assigns 7' do
        semaphore.value = 7
        expect(semaphore.value).to eq(7)
      end
    end

    describe '#try_wait' do
      context 'waiting for 0' do
        it 'should return true' do
          expect(semaphore.try_wait(0)).to be_truthy
        end
      end

      context 'waiting for 1' do
        it 'should return false' do
          expect(semaphore.try_wait(1)).to be_falsey
        end
      end

      context 'waiting for 5' do
        it 'should return false' do
          expect(semaphore.try_wait(5)).to be_falsey
        end
      end

      context 'when a semaphore has a value of 1' do
        before do
          semaphore.value = 1
        end

        context 'waiting for 0' do
          it 'should return false' do
            expect(semaphore.try_wait(0)).to be_falsey
          end
        end

        context 'waiting for 1' do
          it 'should return true' do
            expect(semaphore.try_wait(1)).to be_truthy
          end
        end

        context 'waiting for 5' do
          it 'should return false' do
            expect(semaphore.try_wait(5)).to be_falsey
          end
        end
      end

      context 'when a semaphore has a value of 5' do
        before do
          semaphore.value = 5
        end

        context 'waiting for 0' do
          it 'should return false' do
            expect(semaphore.try_wait(0)).to be_falsey
          end
        end

        context 'waiting for 1' do
          it 'should return true' do
            expect(semaphore.try_wait(1)).to be_truthy
          end
        end

        context 'waiting for 5' do
          it 'should return true' do
            expect(semaphore.try_wait(5)).to be_truthy
          end
        end
      end
    end

    describe '#wait' do
      context 'when another process decrements the semaphore value', slow: true do
        around do |example|
          semaphore.value = 1

          child = fork do
            sleep 0.5
            semaphore.wait
            sleep 5
            exit!
          end

          begin
            example.run
          ensure
            Process.kill('TERM', child)
            Process.wait
          end
        end

        it 'waits for the value to be 0' do
          begin_at = Time.now.to_f
          expect(semaphore.wait(0)).to be_truthy
          expect(Time.now.to_f - begin_at).to be_within(0.1).of(0.5)
        end
      end

      context 'when another process increments the semaphore value', slow: true do
        around do |example|
          subject # reference subject before fork to instantiate the semaphore

          child = fork do
            sleep 0.5
            semaphore.release
            sleep 5
            exit!
          end

          begin
            example.run
          ensure
            Process.kill('TERM', child)
            Process.wait
          end
        end

        it 'waits for value to equal 1' do
          begin_at = Time.now.to_f
          expect(semaphore.wait).to be_truthy
          expect(Time.now.to_f - begin_at).to be_within(0.1).of(0.5)
        end
      end

      context 'when another process increments the semaphore value by 5', slow: true do
        around do |example|
          subject # reference subject before fork to instantiate the semaphore

          child = fork do
            5.times do
              sleep 0.1
              semaphore.release
            end
            sleep 5
            exit!
          end

          begin
            example.run
          ensure
            Process.kill('TERM', child)
            Process.wait
          end
        end

        it 'waits for value to equal 5' do
          begin_at = Time.now.to_f
          expect(semaphore.wait(5)).to be_truthy
          expect(Time.now.to_f - begin_at).to be_within(0.1).of(0.5)
        end
      end
    end

    describe '#waiting_for_value' do
      it 'returns 0' do
        expect(semaphore.waiting_for_value).to eq(0)
      end

      context 'when another process is waiting for the semaphore value to increase', slow: true do
        around do |example|
          subject # reference subject before fork to instantiate the semaphore

          child = fork do
            semaphore.wait
            exit!
          end

          begin
            sleep 0.5
            example.run
          ensure
            Process.kill('TERM', child)
            Process.wait
          end
        end

        it 'returns 1' do
          expect(semaphore.waiting_for_value).to eq(1)
        end
      end
    end

    describe '#waiting_for_zero' do
      # use around instead of before so that it happens before nested around
      around do |example|
        semaphore.value = 1
        example.run
      end

      it 'returns 0' do
        expect(semaphore.waiting_for_zero).to eq(0)
      end

      context 'when another process is waiting for the semaphore value to be zero', slow: true do
        around do |example|
          subject # reference subject before fork to instantiate the semaphore

          child = fork do
            semaphore.wait(0)
            exit!
          end

          begin
            sleep 0.5
            example.run
          ensure
            Process.kill('TERM', child)
            Process.wait
          end
        end

        it 'returns 1' do
          expect(semaphore.waiting_for_zero).to eq(1)
        end
      end
    end
  end
end
