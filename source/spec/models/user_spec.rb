# frozen_string_literal: true

require 'spec_helper'

describe User do
  describe '.login' do
    let!(:user)    { create(:user, password:) }
    let(:password) { 'my_custom_password' }
    let(:login)    { user.login }

    let(:login_hash) do
      {
        login:,
        password:
      }
    end

    context 'when login and password matches' do
      it 'returns user' do
        expect(described_class.login(**login_hash)).to eq(user)
      end
    end

    context 'when login matches but not the password' do
      let(:user) { create(:user) }

      it do
        expect { described_class.login(**login_hash) }
          .to raise_error(PlagueInc::Exception::LoginFailed)
      end
    end

    context 'when login does not matches' do
      let(:login) { 'other_login' }

      it do
        expect { described_class.login(**login_hash) }
          .to raise_error(PlagueInc::Exception::LoginFailed)
      end
    end
  end

  describe '#password=' do
    let(:user)     { build(:user) }
    let(:password) { 'my password' }

    it do
      expect { user.password = password }
        .to change(user, :salt)
    end

    it do
      expect { user.password = password }
        .to change(user, :encrypted_password)
    end

    it 'changes encrypted password to an encrypted value' do
      user.password = password
      expect(user.encrypted_password).not_to eq(password)
    end
  end

  describe '#verify_password!' do
    let(:user)     { create(:user, password:) }
    let(:password) { 'my_custom_password' }

    context 'when password is correct' do
      it 'returns self' do
        expect(user.verify_password!(password)).to eq(user)
      end

      it do
        expect { user.verify_password!(password) }
          .not_to change(user, :salt)
      end
    end

    context 'when password is incorrect' do
      let(:user) { create(:user) }

      it do
        expect { user.verify_password!(password) }
          .to not_change(user, :salt)
          .and raise_error(PlagueInc::Exception::LoginFailed)
      end
    end
  end
end
