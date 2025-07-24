# frozen_string_literal: true

require 'spec_helper'

describe Session do
  describe 'scopes' do
    describe '.active' do
      let!(:session) do
        create(:session, expiration:)
      end

      context 'when session has expiration in the future' do
        let(:expiration) { 2.days.from_now }

        it do
          expect(described_class.active).to include(session)
        end
      end

      context 'when session has expiration in the past' do
        let(:expiration) { 2.days.ago }

        it do
          expect(described_class.active).not_to include(session)
        end
      end

      context 'when session has no expiration' do
        let(:expiration) { nil }

        it do
          expect(described_class.active).to include(session)
        end
      end
    end
  end

  describe 'creates' do
    let(:session) { build(:session) }

    it 'initializes token' do
      expect { session.save }
        .to change(session, :token)
        .from(nil)
    end

    context 'when there is already another session with the same token' do
      let!(:previous_session) { create(:session) }
      let(:new_token) { SecureRandom.base64(48) }
      let(:old_token) { previous_session.token }

      before do
        allow(SecureRandom).to receive(:base64)
          .and_return(old_token, new_token)
      end

      it 'generates a new token' do
        expect(session.tap(&:save).token).to eq(new_token)
      end
    end
  end
end
