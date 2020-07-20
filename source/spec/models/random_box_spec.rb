require 'spec_helper'

describe RandomBox do
  subject(:random_box) { described_class.new }

  describe '<' do
    context 'when random number is bellow threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.5)
      end

      it { expect(random_box < threshold).to be_truthy }
    end

    context 'when random number is above threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.7)
      end

      it { expect(random_box < threshold).to be_falsey }
    end

    context 'when random number is equal threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.6)
      end

      it { expect(random_box < threshold).to be_falsey }
    end
  end

  describe '<=' do
    context 'when random number is bellow threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.5)
      end

      it { expect(random_box <= threshold).to be_truthy }
    end

    context 'when random number is above threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.7)
      end

      it { expect(random_box <= threshold).to be_falsey }
    end

    context 'when random number is equal threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.6)
      end

      it { expect(random_box <= threshold).to be_truthy }
    end
  end

  describe '>' do
    context 'when random number is bellow threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.5)
      end

      it { expect(random_box > threshold).to be_falsey }
    end

    context 'when random number is above threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.7)
      end

      it { expect(random_box > threshold).to be_truthy }
    end

    context 'when random number is equal threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.6)
      end

      it { expect(random_box > threshold).to be_falsey }
    end
  end

  describe '>=' do
    context 'when random number is bellow threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.5)
      end

      it { expect(random_box >= threshold).to be_falsey }
    end

    context 'when random number is above threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.7)
      end

      it { expect(random_box >= threshold).to be_truthy }
    end

    context 'when random number is equal threshold' do
      let(:threshold) { 0.6 }

      before do
        allow(Random).to receive(:rand).with(no_args).and_return(0.6)
      end

      it { expect(random_box >= threshold).to be_truthy }
    end
  end

  describe 'method missing' do
    context 'when not sending arguments' do
      it { expect(subject.rate).to be_in((0...1)) }

      it { expect(subject.rate).to be_a(Float) }
    end

    context 'when sending integer argument' do
      it { expect(subject.person(100)).to be_in((0...100)) }

      it { expect(subject.id(100)).to be_a(Integer) }
    end

    context 'when sending range argument' do
      let(:range) { (100..200) }

      it { expect(subject.choice(range)).to be_in((range)) }

      it { expect(subject.selected(range)).to be_a(Integer) }
    end
  end
end
