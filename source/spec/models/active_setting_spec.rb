# frozen_string_literal: true

require 'spec_helper'

describe ActiveSetting do
  subject(:active_setting) { build(:active_setting, key:) }

  let(:key) { SecureRandom.hex(16) }

  describe 'validations' do
    it do
      expect(active_setting).to validate_presence_of(:key)
    end

    it do
      expect(active_setting).to validate_uniqueness_of(:key)
        .case_insensitive
    end

    it do
      expect(active_setting).to validate_length_of(:key)
        .is_at_most(50)
    end

    context 'when key has all accepted characters' do
      let(:key) { 'some0_key' }

      it { is_expected.to be_valid }
    end

    context 'when key has spaces character' do
      let(:key) { 'some key' }

      it { is_expected.not_to be_valid }
    end

    context 'when key has dash character' do
      let(:key) { 'some-key' }

      it { is_expected.not_to be_valid }
    end

    context 'when key has number in the first character' do
      let(:key) { '0some_key' }

      it { is_expected.not_to be_valid }
    end

    context 'when key has number in the last character' do
      let(:key) { 'some_key0' }

      it { is_expected.to be_valid }
    end

    context 'when key has an underscore in the first character' do
      let(:key) { '_some_key' }

      it { is_expected.to be_valid }
    end

    context 'when key has an underscore in the last character' do
      let(:key) { '_some_key_' }

      it { is_expected.to be_valid }
    end

    it do
      expect(active_setting).to validate_presence_of(:value)
    end

    it do
      expect(active_setting).to validate_length_of(:value)
        .is_at_most(255)
    end
  end

  describe '.for_key' do
    subject(:active_setting) { create(:active_setting) }

    context 'when entry exist' do
      let(:value) { active_setting.value }

      context 'when key upcase key is sent' do
        let(:key) { active_setting.key.upcase }

        it 'returns value from database' do
          expect(described_class.value_for(key)).to eq(value)
        end
      end

      context 'when key downcase key is sent' do
        let(:key) { active_setting.key.downcase }

        it 'returns value from database' do
          expect(described_class.value_for(key)).to eq(value)
        end
      end
    end

    context 'when entry does not exist' do
      let(:key) { 'other_key' }

      it { expect(described_class.value_for(key)).to be_nil }
    end

    context 'when passing a nil key' do
      let(:key) { nil }

      it { expect(described_class.value_for(key)).to be_nil }
    end
  end

  describe 'key=' do
    context 'when the value is upcase' do
      let(:key) { 'SOME_KEY' }

      it 'converts to lowercase' do
        expect(active_setting.key).to eq('some_key')
      end
    end

    context 'when the value is nil' do
      let(:key) { nil }

      it do
        expect(active_setting.key).to be_nil
      end
    end

    context 'when the value is a symbol' do
      let(:key) { :some_key }

      it 'converts to string' do
        expect(active_setting.key).to eq('some_key')
      end
    end
  end
end
