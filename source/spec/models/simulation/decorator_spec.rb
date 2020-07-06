# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Decorator do
  subject(:decorator) { described_class.new(object) }

  let(:attributes) { %w[id name algorithm] }
  let(:settings_attributes) do
    %w[
      lethality days_till_recovery
      days_till_sympthoms days_till_start_death
    ]
  end
  let(:decorator_json) { JSON.parse(decorator.to_json) }

  describe '#to_json' do
    context 'when object is one entity' do
      let(:object) { create(:simulation) }

      let(:group_json) do
        object
          .settings
          .groups
          .first
          .as_json
          .slice('name', 'size', 'reference')
          .merge('behavior' => behavior_json['reference'])
      end

      let(:behavior_json) do
        object
          .settings
          .behaviors
          .first
          .as_json
          .slice('name', 'interactions', 'contagion_risk', 'reference')
      end

      let(:settings_json) do
        object
          .settings
          .as_json
          .slice(*settings_attributes)
          .merge(groups: [group_json])
          .merge(behaviors: [behavior_json])
      end

      let(:expected_json) do
        object
          .as_json
          .slice(*attributes)
          .merge(settings: settings_json)
          .as_json
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is invalid but object has not been validated' do
        let(:object) do
          build(:simulation, name: nil, algorithm: 'invalid')
        end

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is invalid and object has been validated' do
        let(:object) do
          build(
            :simulation,
            name: nil,
            algorithm: 'invalid',
            settings: settings
          )
        end

        let(:settings) do
          build(:contagion, lethality: nil)
        end

        let(:expected_errors) do
          {
            name: ["can't be blank"],
            algorithm: ['is not included in the list'],
            settings: ['is invalid']
          }
        end

        let(:settings_errors) do
          {
            lethality: [
              "can't be blank",
              'is not included in the list'
            ]
          }
        end

        let(:settings_json) do
          settings
            .as_json
            .slice(*settings_attributes)
            .merge(errors: settings_errors)
            .merge(groups: [group_json])
            .merge(behaviors: [behavior_json])
        end

        let(:expected_json) do
          object
            .as_json
            .slice(*attributes)
            .merge(settings: settings_json)
            .merge(errors: expected_errors)
            .deep_stringify_keys
        end

        before { object.valid? }

        it 'returns expected json with errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end

    context 'when object is a collection' do
      let(:object) { build_list(:simulation, 3) }

      let(:expected_json) do
        object.map do |simulation|
          group = simulation.settings.groups.first
          behavior = simulation.settings.behaviors.first
          simulation
            .as_json
            .slice(*attributes)
            .merge(
              settings: simulation.settings
            .as_json.slice(*settings_attributes)
            .merge(groups: [
                     name: group.name,
                     size: group.size,
                     reference: group.reference,
                     behavior: behavior.reference
                   ])
            .merge(behaviors: [
                     name: behavior.name,
                     interactions: behavior.interactions,
                     contagion_risk: behavior.contagion_risk,
                     reference: behavior.reference
                   ])
            )
        end.as_json
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is a collection of invalid not validated objects' do
        let(:object) { build_list(:simulation, 3, name: nil, algorithm: nil) }

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is a collection with invalid ivalidated objects' do
        before { object.each(&:valid?) }

        let(:expected_errors) do
          {
            name: ["can't be blank"],
            algorithm: [
              "can't be blank",
              'is not included in the list'
            ]
          }
        end

        let(:object) { build_list(:simulation, 3, name: nil, algorithm: nil) }

        let(:expected_json) do
          object.map do |simulation|
            group = simulation.settings.groups.first
            behavior = simulation.settings.behaviors.first
            simulation
              .as_json
              .slice(*attributes)
              .merge(
                errors: expected_errors,
                settings: simulation
              .settings
              .as_json.slice(*settings_attributes)
              .merge(groups: [
                       name: group.name,
                       size: group.size,
                       reference: group.reference,
                       behavior: behavior.reference
                     ])
              .merge(behaviors: [
                       name: behavior.name,
                       interactions: behavior.interactions,
                       contagion_risk: behavior.contagion_risk,
                       reference: behavior.reference
                     ])
              )
          end.as_json
        end

        it 'returns expected json' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end
  end
end
