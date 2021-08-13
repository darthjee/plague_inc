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
    let(:simulations_count) { 1 }
    let(:parameters) { {} }

    render_views

    before { create_list(:simulation, simulations_count) }

    context 'when requesting json', :not_cached do
      let(:expected_object) { Simulation.all }

      before do
        get :index, params: parameters.merge(format: :json)
      end

      it { expect(response).to be_successful }

      it 'returns simulations serialized' do
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

      context 'when there are too many simulations' do
        let(:simulations_count) { 21 }
        let(:expected_object)   { Simulation.limit(10) }

        it { expect(response).to be_successful }

        it 'returns simulations serialized' do
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
        let(:simulations_count) { 21 }
        let(:expected_object)   { Simulation.offset(20) }
        let(:parameters)        { { page: 3 } }

        it { expect(response).to be_successful }

        it 'returns simulations serialized' do
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
      let(:size)      { 100 }
      let(:lethality) { 0.5 }
      let(:simulation) { Simulation.last }

      let(:parameters) do
        { format: :json, simulation: payload }
      end

      let(:payload) do
        {
          name: 'my simulation',
          algorithm: 'contagion',
          settings: settings_payload,
          status: 'processing',
          tags: tags
        }
      end

      let(:tags) { ['CustomTag'] }

      let(:settings_payload) do
        {
          lethality: lethality,
          days_till_recovery: 13,
          days_till_sympthoms: 12,
          days_till_start_death: 11,
          days_till_contagion: 10,
          groups: [group_payload],
          behaviors: [behavior_payload]
        }
      end

      let(:group_payload) do
        {
          name: 'Group 1',
          size: size,
          behavior: 'behavior-1',
          reference: 'group-1',
          lethality_override: nil,
          infected: 10
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

      let(:expected_tags) do
        [
          'customtag',
          "size:#{size}",
          "lethality:#{lethality}"
        ]
      end

      before do
        allow(Simulation::ProcessorWorker)
          .to receive(:perform_async)
      end

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

      it do
        post :create, params: parameters

        expect(Simulation::ProcessorWorker)
          .to have_received(:perform_async)
          .with(Simulation.last.id)
      end

      it do
        expect { post :create, params: parameters }
          .to change(Tag, :count)
          .by(3)
      end

      context 'when the request is completed' do
        before { post :create, params: parameters }

        let(:simulation) { Simulation.last }
        let(:settings)   { simulation.settings }
        let(:group)      { settings.groups.first }
        let(:behavior)   { settings.behaviors.first }

        let(:simulation_attributes) do
          simulation.attributes.reject do |key, _|
            %w[id created_at updated_at]
              .include? key
          end
        end

        let(:settings_attributes_ignored) do
          %w[
            id simulation_id created_at
            updated_at days_till_immunization_end
          ]
        end

        let(:settings_attributes) do
          settings.attributes.reject do |key, _|
            settings_attributes_ignored.include? key
          end
        end

        let(:group_attributes) do
          group.attributes.reject do |key, _|
            %w[id contagion_id created_at updated_at]
              .include? key
          end
        end

        let(:behavior_attributes) do
          behavior.attributes.reject do |key, _|
            %w[id contagion_id created_at updated_at]
              .include? key
          end
        end

        let(:expected_simulation_attributes) do
          payload.stringify_keys.reject do |key, _|
            %w[settings tags].include?(key)
          end.merge('status' => 'created', 'checked' => false)
        end

        let(:expected_settings_attributes) do
          settings_payload.stringify_keys.reject do |key, _|
            %w[groups behaviors]
              .include? key
          end
        end

        let(:expected_group_attributes) do
          group_payload
            .reject { |key, _| key == :behavior }
            .merge(behavior_id: behavior.id)
            .stringify_keys
        end

        let(:expected_behavior_attributes) do
          behavior_payload.stringify_keys
        end

        it 'returns created simulation' do
          expect(response.body).to eq(expected_json)
        end

        it 'creates a correct simulation' do
          expect(simulation_attributes)
            .to eq(expected_simulation_attributes)
        end

        it 'creates a correct setting' do
          expect(settings_attributes)
            .to eq(expected_settings_attributes)
        end

        it 'creates a correct group' do
          expect(group_attributes)
            .to eq(expected_group_attributes)
        end

        it 'creates a correct behavior' do
          expect(behavior_attributes)
            .to eq(expected_behavior_attributes)
        end

        it 'creates the expected tags' do
          expect(simulation.tags.pluck(:name))
            .to eq(expected_tags)
        end
      end

      context 'when there are validation errors' do
        let(:payload) { { algorithm: 'invalid', tags: tags } }

        let(:expected_tags) do
          [
            'customtag'
          ]
        end

        let(:simulation_attributes) do
          payload.merge(
            settings: Simulation::Contagion.new,
            tags: [Tag.for(tags.first)]
          )
        end

        let(:simulation) do
          Simulation.new(simulation_attributes).tap(&:valid?)
        end

        it 'is not successful' do
          post :create, params: parameters

          expect(response).not_to be_successful
        end

        it 'does not create a new simulation' do
          expect { post :create, params: parameters }
            .not_to change(Simulation, :count)
        end

        it 'does not create a new tag' do
          expect { post :create, params: parameters }
            .not_to change(Tag, :count)
        end

        it 'returns simulation with errors' do
          post :create, params: parameters

          expect(response.body).to eq(expected_json)
        end

        it do
          expect { post :create, params: parameters }
            .not_to change(Tag, :count)
        end
      end

      context 'when there are validation errors in contagion' do
        let(:settings_payload) { {} }
        let(:simulation) do
          Simulation.new(
            name: 'my simulation',
            algorithm: 'contagion',
            contagion: Simulation::Contagion.new,
            tags: [Tag.for(tags.first)]
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

        it do
          expect { post :create, params: parameters }
            .not_to change(Tag, :count)
        end

        it 'returns simulation with errors' do
          post :create, params: parameters

          expect(response.body).to eq(expected_json)
        end

        it do
          post :create, params: parameters

          expect(Simulation::ProcessorWorker)
            .not_to have_received(:perform_async)
        end
      end
    end
  end

  describe 'GET show' do
    render_views

    let(:simulation)    { create(:simulation) }
    let(:simulation_id) { simulation.id }

    context 'when requesting html and ajax is true', :cached do
      before do
        get :show, params: { format: :html, ajax: true, id: simulation_id }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('simulations/show') }
    end

    context 'when requesting html and ajax is false' do
      before do
        get :show, params: { id: simulation_id }
      end

      it do
        expect(response).to redirect_to("#/simulations/#{simulation_id}")
      end
    end

    context 'when requesting json', :not_cached do
      let(:expected_object) { simulation }

      before do
        get :show, params: { id: simulation_id, format: :json }
      end

      it { expect(response).to be_successful }

      it 'returns simulations serialized' do
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'GET clone' do
    render_views

    let(:simulation)    { create(:simulation) }
    let(:simulation_id) { simulation.id }

    before do
      get :clone, params: parameters
    end

    context 'when requesting html and ajax is true', :cached do
      let(:parameters) do
        { format: :html, ajax: true, simulation_id: simulation_id }
      end

      it { expect(response).to be_successful }

      it { expect(response).to render_template('simulations/clone') }
    end

    context 'when requesting html and ajax is false' do
      let(:parameters) { { simulation_id: simulation_id } }

      it do
        expect(response).to redirect_to("#/simulations/#{simulation_id}/clone")
      end
    end

    context 'when requesting json', :not_cached do
      let(:expected_object) { simulation }

      let(:parameters) { { simulation_id: simulation_id, format: :json } }

      it { expect(response).to be_successful }

      it 'returns simulations serialized' do
        expect(response.body).to eq(expected_json)
      end
    end
  end
end
