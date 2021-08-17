# frozen_string_literal: true

require 'spec_helper'

fdescribe HomeController do
  describe 'GET show' do
    render_views

    context 'when requesting html' do
      before do
        get :show
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('home/show') }
    end

    context 'when requesting json' do
      before do
        get :show, params: { format: :json }
      end

      it { expect(response).to be_successful }

      it { expect(response).to eq(expected_json) }
    end
  end
end
