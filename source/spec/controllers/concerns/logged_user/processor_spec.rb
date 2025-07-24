# frozen_string_literal: true

require 'spec_helper'

describe LoggedUser::Processor do
  subject(:processor) { described_class.new(controller) }

  let(:user)       { create(:user) }
  let(:cookies)    { instance_double(ActionDispatch::Cookies::CookieJar) }
  let(:headers)    { {} }
  let(:controller) do
    instance_double(controller_class, cookies:, headers:)
  end

  let(:signed_cookies) { {} }

  let(:controller_class) do
    Class.new(ApplicationController)
  end

  before do
    allow(cookies).to receive(:signed).and_return(signed_cookies)
  end

  describe '#login' do
    let(:session) { Session.last }

    it 'creates a session' do
      expect { processor.login(user) }
        .to change(Session, :count).by(1)
    end

    it 'sets signed cookie' do
      expect { processor.login(user) }
        .to change { signed_cookies[:session] }
        .from(nil)
    end

    context 'when login has been called' do
      before do
        processor.login(user)
      end

      it 'sets signed cookie to session id' do
        expect(signed_cookies[:session]).to eq(session.id)
      end

      it 'creates session for user' do
        expect(session.user).to eq(user)
      end

      it 'creates a session with expiration date' do
        expect(session.expiration)
          .to be_between(
            Settings.session_period.from_now - 1.second,
            Settings.session_period.from_now
          )
      end
    end
  end

  describe '#logged_user' do
    context 'when user is not logged' do
      it { expect(processor.logged_user).to be_nil }
    end

    context 'when user is logged through cookie' do
      let(:session) do
        create(:session, expiration:, user:)
      end

      before do
        signed_cookies[:session] = session.id
      end

      context 'without expiration' do
        let(:expiration) { nil }

        it 'returns the user' do
          expect(processor.logged_user).to eq(user)
        end
      end

      context 'with expiration in the future' do
        let(:expiration) { 2.days.from_now }

        it 'returns the user' do
          expect(processor.logged_user).to eq(user)
        end
      end

      context 'with expiration in the past' do
        let(:expiration) { 2.days.ago }

        it { expect(processor.logged_user).to be_nil }
      end
    end

    context 'when user is logged with an invalid cookie' do
      let(:signed_cookies) do
        instance_double(ActionDispatch::Cookies::SignedKeyRotatingCookieJar)
      end

      before do
        allow(signed_cookies).to receive(:[]).and_raise(NoMethodError)
      end

      it do
        expect { processor.logged_user }.not_to raise_error
      end

      it { expect(processor.logged_user).to be_nil }
    end

    context 'when user is logged through token' do
      let(:session) do
        create(:session, expiration:, user:)
      end

      before do
        headers['Authorization'] = "Bearer #{session.token}"
      end

      context 'without expiration' do
        let(:expiration) { nil }

        it 'returns the user' do
          expect(processor.logged_user).to eq(user)
        end
      end

      context 'with expiration in the future' do
        let(:expiration) { 2.days.from_now }

        it 'returns the user' do
          expect(processor.logged_user).to eq(user)
        end
      end

      context 'with expiration in the past' do
        let(:expiration) { 2.days.ago }

        it { expect(processor.logged_user).to be_nil }
      end
    end

    context 'when user is logged with an invalid token' do
      before do
        headers['Authorization'] = 'Bearer some token'
      end

      it do
        expect { processor.logged_user }.not_to raise_error
      end

      it { expect(processor.logged_user).to be_nil }
    end
  end

  describe '#logoff' do
    let(:session) do
      create(:session, expiration:, user:)
    end

    before do
      signed_cookies[:session] = session.id

      allow(cookies).to receive(:delete) do |key|
        signed_cookies.delete(key)
      end
    end

    context 'when user is logged with valid session' do
      let(:expiration) { 2.days.from_now }

      it 'change session expiration' do
        expect { processor.logoff }
          .to(change { session.reload.expiration })
      end

      it 'expires session' do
        processor.logoff

        expect(session.reload.expiration)
          .to be < Time.now
      end

      it 'deletes session cookie' do
        expect { processor.logoff }
          .to change { signed_cookies[:session] }
          .to(nil)
      end
    end
  end
end
