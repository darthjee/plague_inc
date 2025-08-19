# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tag::Filter, type: :model do
  describe '#apply' do
    subject(:filter) { described_class.new(filter_hash) }

    let(:scope) { Tag.all }
    let(:attributes) { {} }
    let(:other_attributes) { {} }
    let!(:tag) { create(:tag, **attributes) }
    let!(:other_tag) { create(:tag, **other_attributes) }

    context 'when no filters are provided' do
      let(:filter_hash) { {} }

      it 'returns the original scope unchanged' do
        expect(filter.apply(scope)).to eq(scope)
      end
    end

    context 'when filtering by name' do
      let(:filter_name) { 'epidemic' }
      let(:attributes) { { name: filter_name } }
      let(:other_attributes) { { name: 'pandemic' } }

      let(:filter_hash) { { name: filter_name } }

      context 'when it is an exact match' do
        it 'returns tags matching the name filter' do
          expect(filter.apply(scope)).to include(tag)
        end

        it 'does not return tags not matching the name filter' do
          expect(filter.apply(scope)).not_to include(other_tag)
        end
      end

      context 'when it is not an exact match' do
        let(:filter_name) { 'epi' }
        let(:attributes) { { name: 'epidemic' } }

        it 'does not return tags that partially match the name filter' do
          expect(filter.apply(scope)).not_to include(tag)
        end

        it 'does not return tags that do not match the name filter' do
          expect(filter.apply(scope)).not_to include(other_tag)
        end
      end
    end
  end
end
