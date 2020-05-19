# frozen_string_literal: true

require 'spec_helper'

describe Simulation::SettingsBuilder do
  describe '#build' do
    subject(:builder) { described_class.new(simulation, parameters) }

    let(:simulation) { build(:simulation, settings: nil) }
    let(:parameters) { ActionController::Parameters.new(params) }

    let(:params) do
      {
        simulation: {
          name: 'my simulation',
          algorithm: algorithm,
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
        groups: groups_params
      }
    end

    let(:groups_params) do
      [{ name: 'Group 1', size: 100 }]
    end

    context 'when algorithm is contagion' do
      let(:algorithm) { 'contagion' }

      it 'builds contagion' do
        expect { builder.build }
          .to change(simulation, :settings)
          .from(nil)
          .to(an_instance_of(Simulation::Contagion))
      end

      it 'builds groups' do
        expect { builder.build }
          .to change { simulation.settings.try(:groups) }
          .from(nil)
          .to([an_instance_of(Simulation::Contagion::Group)])
      end

      it do
        expect { builder.build }
          .to change(simulation, :valid?)
          .from(false)
          .to(true)
      end

      context 'when missing settings' do
        let(:params) do
          {
            simulation: {
              name: 'my simulation',
              algorithm: algorithm
            }
          }
        end

        it do
          expect { builder.build }.not_to raise_error
        end

        it do
          expect { builder.build }
            .to change(simulation, :settings)
        end

        it 'builds empty groups' do
          expect { builder.build }
            .to change { simulation.settings.try(:groups) }
            .from(nil)
            .to([])
        end

        it do
          expect { builder.build }
            .not_to change(simulation, :valid?)
        end
      end
    end
  end
end
