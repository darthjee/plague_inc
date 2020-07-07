# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Decorator do
  subject(:decorator) { described_class.new(object) }

  let(:settings_attributes) do
    %w[
      lethality days_till_recovery
      days_till_sympthoms days_till_start_death
    ]
  end
  let(:decorator_json) { JSON.parse(decorator.to_json) }

  describe '#to_json' do
    context 'when object is one entity' do
      let(:object)   { create(:contagion) }
      let(:group)    { object.groups.first }
      let(:behavior) { object.behaviors.first }

      let(:group_json) do
        group
          .as_json
          .slice('name', 'size', 'reference')
          .merge('behavior' => behavior.reference)
      end

      let(:behavior_json) do
        behavior
          .as_json
          .slice('name', 'interactions', 'contagion_risk', 'reference')
      end

      let(:expected_json) do
        object
          .as_json
          .slice(*settings_attributes)
          .merge('groups' => [group_json])
          .merge('behaviors' => [behavior_json])
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is invalid but object has not been validated' do
        let(:object) do
          build(:contagion, lethality: nil)
        end

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is invalid and object has been validated' do
        let(:object) do
          build(:contagion, lethality: nil)
        end

        let(:expected_errors) do
          {
            'lethality' => [
              "can't be blank",
              'is not included in the list'
            ]
          }
        end

        let(:expected_json) do
          object
            .as_json
            .slice(*settings_attributes)
            .merge('errors' => expected_errors)
            .merge('groups' => [group_json])
            .merge('behaviors' => [behavior_json])
        end

        before { object.valid? }

        it 'returns expected json with errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end

    context 'when object is a collection' do
      let(:object) { build_list(:contagion, 3) }

      let(:expected_json) do
        object.map do |settings|
          group = settings.groups.first
          behavior = settings.behaviors.first
          settings
            .as_json.slice(*settings_attributes)
            .merge(groups: [
                     name: group.name,
                     size: group.size,
                     reference: group.reference,
                     behavior: group.behavior.reference
                   ])
            .merge(behaviors: [
                     name: behavior.name,
                     interactions: behavior.interactions,
                     contagion_risk: behavior.contagion_risk,
                     reference: behavior.reference
                   ])
        end.as_json
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is a collection of invalid not validated objects' do
        let(:object) { build_list(:contagion, 3, lethality: nil) }

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is a collection with invalid ivalidated objects' do
        before { object.each(&:valid?) }

        let(:expected_errors) do
          {
            lethality: ["can't be blank", 'is not included in the list']
          }
        end

        let(:object) { build_list(:contagion, 3, lethality: nil) }

        let(:expected_json) do
          object.map do |settings|
            group = settings.groups.first
            behavior = settings.behaviors.first
            settings
              .as_json.slice(*settings_attributes)
              .merge(errors: expected_errors)
              .merge(groups: [
                       name: group.name,
                       size: group.size,
                       reference: group.reference,
                       behavior: group.behavior.reference
                     ])
              .merge(behaviors: [
                       name: behavior.name,
                       interactions: behavior.interactions,
                       contagion_risk: behavior.contagion_risk,
                       reference: behavior.reference
                     ])
          end.as_json
        end

        it 'returns expected json' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end
  end
end
