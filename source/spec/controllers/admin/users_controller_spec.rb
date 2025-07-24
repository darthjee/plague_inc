# frozen_string_literal: true

require 'spec_helper'

describe Admin::UsersController do
  let(:expected_json) do
    User::Decorator.new(expected_object).to_json
  end

  describe 'GET new' do
    render_views

    context 'when requesting html and ajax is true', :cached do
      before do
        get :new, params: { format: :html, ajax: true }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('admin/users/new') }
    end

    context 'when requesting html and ajax is false' do
      before do
        get :new
      end

      it do
        expect(response).to redirect_to('#/admin/users/new')
      end
    end

    context 'when requesting json', :not_cached do
      let(:expected_object) { User.new }

      before do
        get :new, params: { format: :json }
      end

      it { expect(response).to be_successful }

      it 'returns users serialized' do
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'GET index' do
    let(:users_count) { 1 }
    let(:parameters) { {} }

    render_views

    before { create_list(:user, users_count) }

    context 'when requesting json', :not_cached do
      let(:expected_object) { User.all }

      before do
        get :index, params: parameters.merge(format: :json)
      end

      it { expect(response).to be_successful }

      it 'returns users serialized' do
        expect(response.body).to eq(expected_json)
      end

      it 'adds page header' do
        expect(response.headers['page']).to eq(1)
      end

      it 'adds pages header' do
        expect(response.headers['pages']).to eq(1)
      end

      it 'adds per_page header' do
        expect(response.headers['per_page']).to eq(10)
      end

      context 'when there are too many users' do
        let(:users_count) { 21 }
        let(:expected_object) { User.limit(10) }

        it { expect(response).to be_successful }

        it 'returns users serialized' do
          expect(response.body).to eq(expected_json)
        end

        it 'adds page header' do
          expect(response.headers['page']).to eq(1)
        end

        it 'adds pages header' do
          expect(response.headers['pages']).to eq(3)
        end

        it 'adds per_page header' do
          expect(response.headers['per_page']).to eq(10)
        end
      end

      context 'when requesting last page' do
        let(:users_count) { 21 }
        let(:expected_object) { User.offset(20) }
        let(:parameters)      { { page: 3 } }

        it { expect(response).to be_successful }

        it 'returns users serialized' do
          expect(response.body).to eq(expected_json)
        end

        it 'adds page header' do
          expect(response.headers['page']).to eq(3)
        end

        it 'adds pages header' do
          expect(response.headers['pages']).to eq(3)
        end

        it 'adds per_page header' do
          expect(response.headers['per_page']).to eq(10)
        end
      end
    end

    context 'when requesting html and ajax is true', :cached do
      before do
        get :index, params: { format: :html, ajax: true }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('admin/users/index') }
    end

    context 'when requesting html and ajax is false' do
      before do
        get :index
      end

      it { expect(response).to redirect_to('#/admin/users') }
    end
  end

  describe 'POST create' do
    context 'when requesting json format' do
      let(:user) { User.last }

      let(:parameters) do
        { format: :json, **payload }
      end

      let(:expected_object) { user }
      let(:payload) do
        {
          name: 'my user',
          login: 'my_user',
          password: '123456',
          email: 'usr@srv.com'
        }
      end

      it do
        post :create, params: parameters

        expect(response).to be_successful
      end

      it do
        expect { post :create, params: parameters }
          .to change(User, :count)
          .by(1)
      end

      context 'when the request is completed' do
        before { post :create, params: parameters }

        let(:user) { User.last }

        let(:user_attributes) do
          user.attributes
              .except('id', 'created_at', 'updated_at', 'encrypted_password', 'salt', 'admin')
        end

        let(:expected_user_attributes) do
          payload.stringify_keys.except('password')
        end

        it 'returns created user' do
          expect(response.body).to eq(expected_json)
        end

        it 'creates a correct user' do
          expect(user_attributes)
            .to eq(expected_user_attributes)
        end
      end

      context 'when there are validation errors' do
        let(:payload) { { name: '' } }

        let(:user_attributes) do
          payload
        end

        let(:user) do
          User.new(user_attributes).tap(&:valid?)
        end

        it 'is not successful' do
          post :create, params: parameters

          expect(response).not_to be_successful
        end

        it 'does not create a new user' do
          expect { post :create, params: parameters }
            .not_to change(User, :count)
        end

        it 'returns user with errors' do
          post :create, params: parameters

          expect(response.body).to eq(expected_json)
        end
      end
    end
  end

  describe 'GET show' do
    render_views

    let(:user)    { create(:user) }
    let(:user_id) { user.id }

    context 'when requesting html and ajax is true', :cached do
      before do
        get :show, params: { format: :html, ajax: true, id: user_id }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('admin/users/show') }
    end

    context 'when requesting html and ajax is false' do
      before do
        get :show, params: { id: user_id }
      end

      it do
        expect(response).to redirect_to("#/admin/users/#{user_id}")
      end
    end

    context 'when requesting json', :not_cached do
      let(:expected_object) { user }

      before do
        get :show, params: { id: user_id, format: :json }
      end

      it { expect(response).to be_successful }

      it 'returns users serialized' do
        expect(response.body).to eq(expected_json)
      end
    end
  end
end
