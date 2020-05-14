# frozen_string_literal: true

require 'spec_helper'

describe SimulationsController do
  let(:expected_json) do
    Simulation::Decorator.new(expected_object).to_json
  end

  describe 'GET new' do
    render_views

    context 'when requesting html and ajax is true', :cached do
      before do
        get :new, params: { format: :html, ajax: true }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('simulations/new') }
    end

    context 'when requesting html and ajax is false' do
      before do
        get :new
      end

      it do
        expect(response).to redirect_to('#/simulations/new')
      end
    end

    context 'when requesting json', :not_cached do
      let(:expected_object) { Simulation.new }

      before do
        get :new, params: { format: :json }
      end

      it { expect(response).to be_successful }

      it 'returns simulations serialized' do
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'GET index' do
    render_views

    before { create_list(:simulation, 1) }

    context 'when requesting json', :not_cached do
      let(:expected_object) { Simulation.all }

      before do
        get :index, params: { format: :json }
      end

      it { expect(response).to be_successful }

      it 'returns simulations serialized' do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when requesting html and ajax is true', :cached do
      before do
        get :index, params: { format: :html, ajax: true }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('simulations/index') }
    end

    context 'when requesting html and ajax is false' do
      before do
        get :index
      end

      it { expect(response).to redirect_to('#/simulations') }
    end
  end

  fdescribe 'POST create' do
    context 'when requesting json format' do
      let(:simulation) { Simulation.last }
      let(:parameters) do
        { format: :json, simulation: payload }
      end
      let(:payload) do
        {
          name: 'my simulation',
          algorithm: 'contagion',
          settings: {
            lethality: 0.5,
            days_till_recovery: 13,
            days_till_sympthoms: 12,
            days_till_start_death: 11
          }
        }
      end

      let(:expected_object) { simulation }

      it do
        post :create, params: parameters

        expect(response).to be_successful
      end

      it do
        expect { post :create, params: parameters }
          .to change(Simulation, :count)
          .by(1)
      end

      it do
        expect { post :create, params: parameters }
          .to change(Simulation::Contagion, :count)
          .by(1)
      end

      it 'returns created simulation' do
        post :create, params: parameters

        expect(response.body).to eq(expected_json)
      end

      context 'when there are errors' do
        let(:payload)    { { algorithm: 'invalid' } }
        let(:simulation) { Simulation.new(payload).tap(&:valid?) }

        it do
          post :create, params: parameters

          expect(response).not_to be_successful
        end

        it do
          expect { post :create, params: parameters }
            .not_to change(Simulation, :count)
        end

        it 'returns simulation with errors' do
          post :create, params: parameters

          expect(response.body).to eq(expected_json)
        end
      end
    end
  end
end
