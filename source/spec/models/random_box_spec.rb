require 'spec_helper'

describe RandomBox do
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
