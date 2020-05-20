# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Builder do
  subject(:builder) do
    described_class.new(parameters, collection)
  end

  let(:collection) { Simulation.all }
  let(:parameters) { ActionController::Parameters.new(params) }
  let(:params) do
    {
      simulation: {
        name: 'my simulation',
        algorithm: 'contagion',
        settings: settings_params
      }
    }
  end

  let(:settings_params) do
    {
      lethality: 0.5,
      days_till_recovery: 13,
      days_till_sympthoms: 12,
      days_till_start_death: 11,
      groups: [group_params]
    }
  end

  let(:group_params) do
    {
      name: 'Group 1',
      size: 100
    }
  end

  describe '#build' do
    let(:expected_simulation) do
      Simulation.new(
        name: 'my simulation',
        algorithm: 'contagion'
      )
    end

    it { expect(builder.build).to be_a(Simulation) }

    it do
      expect(builder.build.as_json)
        .to eq(expected_simulation.as_json)
    end
  end
end
