# frozen_string_literal: true

require 'spec_helper'

describe LoginController do
  let(:user)     { create(:user, password:) }
  let(:login)    { user.login }
  let(:password) { 'password' }

  let(:request_password) { password }

  let(:expected_json) do
    Session::Decorator.new(session).to_json
  end

  let(:parameters) do
    {
      login: {
        login:,
        password: request_password
      }
    }
  end

  describe 'POST create' do
    let(:session) { user.sessions.last }

    context 'when login is correct' do
      it 'creates a session' do
        expect do
          post :create, params: parameters
        end.to change(Session, :count).by(1)
      end

      it 'adds session to cookie' do
        expect { post :create, params: parameters }
          .to change { cookies[:session] }
          .from(nil)
      end

      context 'when request is done' do
        let(:created_session) { Session.last }

        before do
          post :create, params: parameters
        end

        it do
          expect(response).to be_successful
        end

        it 'returns user serialized' do
          expect(response.body).to eq(expected_json)
        end

        it 'creates a session for the user' do
          expect(created_session.user).to eq(user)
        end

        it 'creates a session that will expire' do
          expect(created_session.expiration)
            .to be_in(Time.now..Settings.session_period.from_now)
        end

        it 'stores session in cookies' do
          expect(cookies.signed[:session]).to eq(created_session.id)
        end
      end
    end

    context 'when request is a failure due to bad password' do
      let(:request_password) { 'wrong_pass' }

      it 'does not create a session' do
        expect do
          post :create, params: parameters
        end.not_to change(Session, :count)
      end

      it 'does not add session to cookie' do
        expect do
          post :create, params: parameters
        end.not_to(change { cookies[:session] })
      end

      context 'when the request is completed' do
        before do
          post :create, params: parameters
        end

        it do
          expect(response).not_to be_successful
        end

        it do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when request is a failure due to bad login' do
      let(:login) { 'wrong_login' }

      it 'does not create a session' do
        expect do
          post :create, params: parameters
        end.not_to change(Session, :count)
      end

      it 'does not add session to cookie' do
        expect do
          post :create, params: parameters
        end.not_to(change { cookies[:session] })
      end

      context 'when the request is completed' do
        before do
          post :create, params: parameters
        end

        it do
          expect(response).not_to be_successful
        end

        it do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe '#check' do
      before do
        cookies.signed[:session] = session.id if session

        get :check, format: :json
      end

      context 'when user is not logged' do
        let(:session) { nil }

        it { expect(response).not_to be_successful }

        it { expect(response).to have_http_status(:not_found) }
      end

      context 'when user is logged' do
        let(:session) { create(:session, user:) }

        it { expect(response).to be_successful }

        it 'returns user serialized' do
          expect(response.body).to eq(expected_json)
        end
      end

      context 'when user is logged with expired session' do
        let(:session) { create(:session, :expired, user:) }

        it { expect(response).not_to be_successful }

        it { expect(response).to have_http_status(:not_found) }
      end
    end
  end

  describe 'DELETE logoff' do
    let(:session) { create(:session, user:) }

    before do
      controller.send(:cookies).signed[:session] = session.id
    end

    it do
      expect { delete :logoff }
        .to change { controller.send(:cookies)[:session] }
        .to(nil)
    end

    it 'expires session' do
      expect { delete :logoff }
        .to change { session.reload.expiration }
        .from(nil)
    end

    context 'when the request is finished' do
      before do
        delete :logoff
      end

      it 'expires session' do
        expect(session.reload.expiration)
          .to be < Time.now
      end
    end
  end
end
