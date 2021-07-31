# frozen_string_literal: true

require 'spec_helper'

describe Tag, type: :model do
  subject(:tag) { build(:tag) }

  describe 'validations' do
    it do
      expect(tag).to validate_presence_of(:name)
    end

    it do
      expect(tag).to validate_length_of(:name)
        .is_at_most(50)
    end
  end

  describe '#save' do
    subject(:tag) { build(:tag, name: name) }

    let(:name) { 'My tagName' }

    it do
      expect { tag.tap(&:save).reload }
        .to change(tag, :name)
        .to('my tagname')
    end
  end

  describe '.for' do
    let(:name) { 'My tagName' }

    context 'when there is no tag' do
      before { create(:tag) }

      it do
        expect(described_class.for(name))
          .to be_a(described_class)
      end

      it do
        expect(described_class.for(name))
          .not_to be_persisted
      end
    end

    context 'when there a tag' do
      let!(:previous_tag) { create(:tag, name: name) }

      it do
        expect(described_class.for(name))
          .to be_a(described_class)
      end

      it do
        expect(described_class.for(name))
          .to be_persisted
      end

      it 'returns already created tag' do
        expect(described_class.for(name))
          .to eq(previous_tag)
      end
    end
  end
end
