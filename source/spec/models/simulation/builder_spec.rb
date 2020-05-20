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
        algorithm: 'contagion',
        settings: expected_settings
      )
    end

    let(:expected_settings) do
      Simulation::Contagion.new(
        lethality: 0.5,
        days_till_recovery: 13,
        days_till_sympthoms: 12,
        days_till_start_death: 11,
        groups: [expected_group]
      )
    end

    let(:expected_group) do
      Simulation::Contagion::Group.new(
        name: 'Group 1',
        size: 100
      )
    end

    it { expect(builder.build).to be_a(Simulation) }

    it { expect(builder.build).to be_valid }

    it do
      expect(builder.build.as_json)
        .to eq(expected_simulation.as_json)
    end

    it 'builds settings' do
      expect(builder.build.settings)
        .not_to be_nil
    end

    it 'builds a contagion' do
      expect(builder.build.settings)
        .to be_a(Simulation::Contagion)
    end

    it 'builds settings with attributes' do
      expect(builder.build.settings.to_json)
        .to eq(expected_settings.to_json)
    end

    it 'builds groups' do
      expect(builder.build.settings.groups)
        .not_to be_empty
    end

    it 'builds a correct group' do
      expect(builder.build.settings.groups)
        .to all(be_a(Simulation::Contagion::Group))
    end

    it 'builds groups with attributes' do
      expect(builder.build.settings.groups.to_json)
        .to eq([expected_group].to_json)
    end
  end
end
