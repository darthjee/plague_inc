# frozen_string_literal: true

require 'spec_helper'

fdescribe HomeController do
  describe 'GET show' do
    render_views

    context 'when requesting html' do
      before do
        get :show, params: { ajax: true }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('home/show') }
    end

    context 'when requesting json' do
      let(:parsed_body) { JSON.parse(response.body) }

      let(:statuses_json) do
        (1..Simulation::STATUSES.size).to_a.as_hash(
          Simulation::STATUSES
        )
      end

      let(:expected_json) do
        {
          'statuses' => statuses_json,
          'finished' => { 'false' => 3, 'true' => 1 }
        }
      end

      before do
        statuses_json.each do |status, count|
          create_list(:simulation, count, status)
        end
        Simulation.finished.first.update(checked: true)

        get :show, params: { format: :json }
      end

      it { expect(response).to be_successful }

      it { expect(parsed_body).to eq(expected_json) }
    end
  end
end
