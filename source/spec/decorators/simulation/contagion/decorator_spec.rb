# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Decorator do
  subject(:decorator) { described_class.new(object) }

  let(:settings_attributes) do
    %w[
      lethality days_till_recovery
      days_till_sympthoms days_till_start_death
      days_till_contagion
    ]
  end
  let(:decorator_json) { JSON.parse(decorator.to_json) }

  describe '#to_json' do
    context 'when object is one entity' do
      let(:object)   { create(:contagion) }
      let(:group)    { object.groups.first }
      let(:behavior) { object.behaviors.first }

      let(:group_json) do
        Simulation::Contagion::Group::Decorator.new(group).as_json
      end

      let(:behavior_json) do
        Simulation::Contagion::Behavior::Decorator.new(behavior).as_json
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
          groups = settings.groups
          groups_json = Simulation::Contagion::Group::Decorator.new(
            groups
          ).as_json
          behaviors = settings.behaviors
          behaviors_json = Simulation::Contagion::Behavior::Decorator.new(
            behaviors
          ).as_json

          settings
            .as_json.slice(*settings_attributes)
            .merge(groups: groups_json)
            .merge(behaviors: behaviors_json)
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
            groups = settings.groups
            groups_json = Simulation::Contagion::Group::Decorator.new(
              groups
            ).as_json
            behaviors = settings.behaviors
            behaviors_json = Simulation::Contagion::Behavior::Decorator.new(
              behaviors
            ).as_json
            settings
              .as_json.slice(*settings_attributes)
              .merge(errors: expected_errors)
              .merge(groups: groups_json)
              .merge(behaviors: behaviors_json)
          end.as_json
        end

        it 'returns expected json' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end
  end
end
