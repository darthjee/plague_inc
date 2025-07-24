# frozen_string_literal: true

require 'spec_helper'

describe UsersController do
  let(:expected_json) do
    User::Decorator.new(expected_object).to_json
  end

  describe 'GET index' do
    render_views

    before { create_list(:user, 3) }

    context 'when requesting json', :not_cached do
      let(:expected_object) { User.all }

      before do
        get :index, params: { format: :json }
      end

      it { expect(response).to be_successful }

      it 'returns measurements serialized' do
        expect(response.body).to eq(expected_json)
      end
    end
  end
end
