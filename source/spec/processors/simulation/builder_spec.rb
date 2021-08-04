# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Builder do
  subject(:simulation) do
    described_class.process(parameters, collection)
  end

  let(:collection) { Simulation.all }
  let(:parameters) { ActionController::Parameters.new(params) }
  let(:lethality)  { Random.rand(3..7) / 10.0 }
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
      lethality: lethality,
      days_till_recovery: 13,
      days_till_sympthoms: 12,
      days_till_start_death: 11,
      groups: [group_params].compact,
      behaviors: [behavior_params].compact
    }
  end

  let(:size) { Random.rand(300..1000) }

  let(:group_params) do
    {
      name: 'Group 1',
      size: size,
      reference: 'group-1',
      behavior: 'behavior-1'
    }
  end

  let(:behavior_params) do
    {
      name: 'My Behavior',
      interactions: 15,
      contagion_risk: 0.5,
      reference: 'behavior-1'
    }
  end

  describe '.build' do
    let(:expected_simulation) do
      Simulation.new(
        name: 'my simulation',
        algorithm: 'contagion',
        settings: expected_settings
      )
    end

    let(:expected_settings) do
      Simulation::Contagion.new(
        lethality: lethality,
        days_till_recovery: 13,
        days_till_sympthoms: 12,
        days_till_start_death: 11,
        groups: [expected_group]
      )
    end

    let(:expected_group) do
      Simulation::Contagion::Group.new(
        name: 'Group 1',
        size: size,
        reference: 'group-1',
        behavior: expected_behavior
      )
    end

    let(:expected_behavior) do
      Simulation::Contagion::Behavior.new(
        name: 'My Behavior',
        interactions: 15,
        contagion_risk: 0.5,
        reference: 'behavior-1'
      )
    end

    let(:expected_tags) do
      [
        "size:#{size}",
        "lethality:#{lethality}"
      ]
    end

    it { expect(simulation).to be_a(Simulation) }

    it { expect(simulation).to be_valid }

    it do
      expect(simulation.as_json)
        .to eq(expected_simulation.as_json)
    end

    it 'builds settings' do
      expect(simulation.settings)
        .not_to be_nil
    end

    it 'builds a contagion' do
      expect(simulation.settings)
        .to be_a(Simulation::Contagion)
    end

    it 'builds settings with attributes' do
      expect(simulation.settings.to_json)
        .to eq(expected_settings.to_json)
    end

    it 'builds groups' do
      expect(simulation.settings.groups)
        .not_to be_empty
    end

    it 'builds a correct group' do
      expect(simulation.settings.groups)
        .to all(be_a(Simulation::Contagion::Group))
    end

    it 'connects behavior to group' do
      expect(simulation.settings.groups.first.behavior)
        .to eq(simulation.settings.behaviors.first)
    end

    it 'builds groups with attributes' do
      expect(simulation.settings.groups.to_json)
        .to eq([expected_group].to_json)
    end

    it 'builds a correct behavior' do
      expect(simulation.settings.behaviors)
        .to all(be_a(Simulation::Contagion::Behavior))
    end

    it 'builds behaviors with attributes' do
      expect(simulation.settings.behaviors.to_json)
        .to eq([expected_behavior].to_json)
    end

    it 'builds tags' do
      expect(simulation.tags.map(&:name))
        .to match_array(expected_tags)
    end

    context 'when there is no group' do
      let(:group_params) { nil }

      let(:expected_tags) { [] }

      it { expect(simulation).to be_a(Simulation) }

      it { expect(simulation).not_to be_valid }

      it do
        expect(simulation.as_json)
          .to eq(expected_simulation.as_json)
      end

      it 'builds settings' do
        expect(simulation.settings)
          .not_to be_nil
      end

      it 'builds a contagion' do
        expect(simulation.settings)
          .to be_a(Simulation::Contagion)
      end

      it 'builds settings with attributes' do
        expect(simulation.settings.to_json)
          .to eq(expected_settings.to_json)
      end

      it 'builds no group' do
        expect(simulation.settings.groups)
          .to be_empty
      end

      it 'builds a correct behavior' do
        expect(simulation.settings.behaviors)
          .to all(be_a(Simulation::Contagion::Behavior))
      end

      it 'builds behaviors with attributes' do
        expect(simulation.settings.behaviors.to_json)
          .to eq([expected_behavior].to_json)
      end

      it 'builds no default tags' do
        expect(simulation.tags.map(&:name))
          .to match_array(expected_tags)
      end
    end

    context 'when group misses behavior' do
      let(:group_params) do
        {
          name: 'Group 1',
          size: size,
          reference: 'group-1'
        }
      end

      let(:expected_tags) { [] }

      it { expect(simulation).to be_a(Simulation) }

      it { expect(simulation).not_to be_valid }

      it do
        expect(simulation.as_json)
          .to eq(expected_simulation.as_json)
      end

      it 'builds settings' do
        expect(simulation.settings)
          .not_to be_nil
      end

      it 'builds a contagion' do
        expect(simulation.settings)
          .to be_a(Simulation::Contagion)
      end

      it 'builds settings with attributes' do
        expect(simulation.settings.to_json)
          .to eq(expected_settings.to_json)
      end

      it 'builds groups' do
        expect(simulation.settings.groups)
          .not_to be_empty
      end

      it 'builds a correct group' do
        expect(simulation.settings.groups)
          .to all(be_a(Simulation::Contagion::Group))
      end

      it 'does not connect behavior to group' do
        expect(simulation.settings.groups.first.behavior)
          .to be_nil
      end

      it 'builds groups with attributes' do
        expect(simulation.settings.groups.to_json)
          .to eq([expected_group].to_json)
      end

      it 'builds a correct behavior' do
        expect(simulation.settings.behaviors)
          .to all(be_a(Simulation::Contagion::Behavior))
      end

      it 'builds behaviors with attributes' do
        expect(simulation.settings.behaviors.to_json)
          .to eq([expected_behavior].to_json)
      end

      it 'builds no default tags' do
        expect(simulation.tags.map(&:name))
          .to match_array(expected_tags)
      end
    end

    context 'when there are no behaviors' do
      let(:behavior_params) { nil }
      let(:expected_tags)   { [] }

      it { expect(simulation).to be_a(Simulation) }

      it { expect(simulation).not_to be_valid }

      it do
        expect(simulation.as_json)
          .to eq(expected_simulation.as_json)
      end

      it 'builds settings' do
        expect(simulation.settings)
          .not_to be_nil
      end

      it 'builds a contagion' do
        expect(simulation.settings)
          .to be_a(Simulation::Contagion)
      end

      it 'builds settings with attributes' do
        expect(simulation.settings.to_json)
          .to eq(expected_settings.to_json)
      end

      it 'builds groups' do
        expect(simulation.settings.groups)
          .not_to be_empty
      end

      it 'builds a correct group' do
        expect(simulation.settings.groups)
          .to all(be_a(Simulation::Contagion::Group))
      end

      it 'does not connect behavior to group' do
        expect(simulation.settings.groups.first.behavior)
          .to be_nil
      end

      it 'builds groups with attributes' do
        expect(simulation.settings.groups.to_json)
          .to eq([expected_group].to_json)
      end

      it 'does not build behaviors' do
        expect(simulation.settings.behaviors)
          .to be_empty
      end

      it 'builds no default tags' do
        expect(simulation.tags.map(&:name))
          .to match_array(expected_tags)
      end
    end

    context 'when settings payload and algorithm are missing' do
      let(:params) do
        {
          simulation: {
            name: 'my simulation'
          }
        }
      end
      let(:expected_tags)   { [] }

      let(:expected_simulation) do
        Simulation.new(
          name: 'my simulation'
        )
      end

      it { expect(simulation).to be_a(Simulation) }

      it { expect(simulation).not_to be_valid }

      it do
        expect(simulation.as_json)
          .to eq(expected_simulation.as_json)
      end

      it 'does not generate settings' do
        expect(simulation.settings).to be_nil
      end

      it 'builds no default tags' do
        expect(simulation.tags.map(&:name))
          .to match_array(expected_tags)
      end
    end

    context 'when settings payload is missing' do
      let(:params) do
        {
          simulation: {
            name: 'my simulation',
            algorithm: 'contagion'
          }
        }
      end
      let(:expected_tags) { [] }

      let(:expected_simulation) do
        Simulation.new(
          name: 'my simulation',
          algorithm: 'contagion',
          settings: Simulation::Contagion.new
        )
      end

      it { expect(simulation).to be_a(Simulation) }

      it { expect(simulation).not_to be_valid }

      it do
        expect(simulation.as_json)
          .to eq(expected_simulation.as_json)
      end

      it 'generate settings empty settings' do
        expect(simulation.settings).to be_a(Simulation::Contagion)
      end

      it 'builds no default tags' do
        expect(simulation.tags.map(&:name))
          .to match_array(expected_tags)
      end
    end

    context 'when group payload is missing' do
      let(:expected_tags) { [] }

      let(:settings_params) do
        {
          lethality: lethality,
          days_till_recovery: 13,
          days_till_sympthoms: 12,
          days_till_start_death: 11
        }
      end

      let(:expected_settings) do
        Simulation::Contagion.new(
          lethality: lethality,
          days_till_recovery: 13,
          days_till_sympthoms: 12,
          days_till_start_death: 11
        )
      end

      it { expect(simulation).to be_a(Simulation) }

      it { expect(simulation).not_to be_valid }

      it do
        expect(simulation.as_json)
          .to eq(expected_simulation.as_json)
      end

      it 'builds a contagion' do
        expect(simulation.settings)
          .to be_a(Simulation::Contagion)
      end

      it 'builds settings with attributes' do
        expect(simulation.settings.to_json)
          .to eq(expected_settings.to_json)
      end

      it 'does not generate groups' do
        expect(simulation.settings.groups).to be_empty
      end

      it 'builds no default tags' do
        expect(simulation.tags.map(&:name))
          .to match_array(expected_tags)
      end
    end
  end
end
