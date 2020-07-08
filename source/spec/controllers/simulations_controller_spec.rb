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

  describe 'POST create' do
    context 'when requesting json format' do
      let(:simulation) { Simulation.last }
      let(:parameters) do
        { format: :json, simulation: payload }
      end
      let(:payload) do
        {
          name: 'my simulation',
          algorithm: 'contagion',
          settings: settings_payload
        }
      end

      let(:settings_payload) do
        {
          lethality: 0.5,
          days_till_recovery: 13,
          days_till_sympthoms: 12,
          days_till_start_death: 11,
          groups: [group_payload],
          behaviors: [behavior_payload]
        }
      end

      let(:group_payload) do
        {
          name: 'Group 1',
          size: 100,
          behavior: 'behavior-1',
          reference: 'group-1',
          infection: 10
        }
      end

      let(:behavior_payload) do
        {
          name: 'My Behavior',
          interactions: 15,
          contagion_risk: 0.5,
          reference: 'behavior-1'
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

      it do
        expect { post :create, params: parameters }
          .to change(Simulation::Contagion::Group, :count)
          .by(1)
      end

      it do
        expect { post :create, params: parameters }
          .to change(Simulation::Contagion::Behavior, :count)
          .by(1)
      end

      it 'returns created simulation' do
        post :create, params: parameters

        expect(response.body).to eq(expected_json)
      end

      context 'when there are validation errors' do
        let(:payload) { { algorithm: 'invalid' } }

        let(:simulation_attributes) do
          payload.merge(settings: Simulation::Contagion.new)
        end

        let(:simulation) do
          Simulation.new(simulation_attributes).tap(&:valid?)
        end

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

      context 'when there are validation errors in contagion' do
        let(:settings_payload) { {} }
        let(:simulation) do
          Simulation.new(
            name: 'my simulation',
            algorithm: 'contagion',
            contagion: Simulation::Contagion.new
          ).tap(&:valid?)
        end

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
