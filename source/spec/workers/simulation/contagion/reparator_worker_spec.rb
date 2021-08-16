# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Contagion::ReparatorWorker do
  let(:simulation_id) { simulation.id }
  let(:simulation)   { contagion.simulation }
  let(:size)         { 800 }
  let(:group)        { contagion.groups.first }
  let(:checked)      { false }
  let(:status)       { Simulation::FINISHED }
  let(:not_finished) do
    (Simulation::STATUSES - [Simulation::FINISHED]).sample
  end
  let(:contagion) do
    create(
      :contagion,
      size: size,
      status: status,
      days_till_recovery: 1,
      days_till_sympthoms: 0,
      days_till_start_death: 1,
      lethality: 1,
      checked: checked
    )
  end

  describe '#perform' do
    subject(:perform) do
      described_class.new.perform(simulation_id, day)
    end

    let(:day) { 0 }

    context 'when there is only one instant' do
      include_context 'with instant incomplete', 0

      it do
        expect { perform }.to change { simulation.reload.status }
          .to(Simulation::CREATED)
      end

      it 'removes all instants' do
        expect { perform }
          .to change { simulation.reload.contagion.instants.size }
          .to(0)
      end

      it 'removes populations' do
        expect { perform }
          .to change(Simulation::Contagion::Population, :count)
          .by(-1)
      end
    end

    context 'when there are 2 instants instant' do
      let(:day) { 1 }

      include_context 'with instant complete', 0
      include_context 'with instant incomplete', 1

      it do
        expect { perform }.to change { simulation.reload.status }
          .to(Simulation::CREATED)
      end

      it 'removes all instants' do
        expect { perform }
          .to change { simulation.reload.contagion.instants.size }
          .to(0)
      end

      it 'removes populations' do
        expect { perform }
          .to change(Simulation::Contagion::Population, :count)
          .by(-5)
      end
    end

    context 'when there are more than 2 instants instant' do
      include_context 'with instant complete', 0
      include_context 'with instant complete', 1
      include_context 'with instant incomplete', 2
      include_context 'with instant incomplete', 3

      context 'when passing day 3 and simulation is fixing' do
        let(:day)    { 3 }
        let(:status) { Simulation::FIXING }

        it do
          expect { perform }.to change { simulation.reload.status }
            .to(Simulation::CREATED)
        end

        it 'removes all instants' do
          expect { perform }
            .to change { simulation.reload.contagion.instants.size }
            .to(0)
        end

        it 'removes populations' do
          expect { perform }
            .to change(Simulation::Contagion::Population, :count)
            .by(-16)
        end
      end

      context 'when passing day 0' do
        let(:day) { 0 }

        it do
          expect { perform }.to change { simulation.reload.status }
            .to(Simulation::CREATED)
        end

        it 'removes all instants' do
          expect { perform }
            .to change { simulation.reload.contagion.instants.size }
            .to(0)
        end

        it 'removes populations' do
          expect { perform }
            .to change(Simulation::Contagion::Population, :count)
            .by(-16)
        end
      end

      context 'when passing day 1' do
        let(:day) { 1 }

        it do
          expect { perform }.to change { simulation.reload.status }
            .to(Simulation::CREATED)
        end

        it 'removes all instants' do
          expect { perform }
            .to change { simulation.reload.contagion.instants.size }
            .to(0)
        end

        it 'removes populations' do
          expect { perform }
            .to change(Simulation::Contagion::Population, :count)
            .by(-16)
        end
      end

      context 'when passing day 2' do
        let(:day) { 2 }

        it do
          expect { perform }.to change { simulation.reload.status }
            .to(Simulation::PROCESSED)
        end

        it 'Deletes only instants after the selected instant' do
          expect { perform }
            .to change { simulation.reload.contagion.instants.size }
            .by(-1)
        end

        it 'removes populations of removed instants' do
          expect { perform }
            .to change(Simulation::Contagion::Population, :count)
            .by(-4)
        end

        it 'correct populations size' do
          expect { perform }
            .to change {
              contagion.instants.find_by(day: 2).populations.sum(:size)
            }
            .to(size)
        end

        it 'correct healthy population' do
          expect { perform }
            .to change {
              contagion.reload.instants.find_by(day: 2)
                       .populations.healthy.sum(:size)
            } .to(788)
        end

        it 'kills population' do
          perform

          expect(
            contagion.reload.instants.find_by(day: 2)
            .populations.dead.find_by(days: 0).size
          ).to eq(4)
        end

        it 'marks instant as ready' do
          expect { perform }
            .to change { contagion.reload.instants.find_by(day: 2).status }
            .to Simulation::Contagion::Instant::READY
        end
      end

      context 'when passing day 3' do
        let(:day) { 3 }

        it do
          expect { perform }.to change { simulation.reload.status }
            .to(Simulation::PROCESSED)
        end

        it 'Deletes only instants after the selected instant' do
          expect { perform }
            .not_to(change { simulation.reload.contagion.instants.size })
        end

        it 'removes populations of removed instants' do
          expect { perform }
            .not_to change(Simulation::Contagion::Population, :count)
        end

        it 'correct populations size' do
          expect { perform }
            .not_to(change do
              contagion.instants.find_by(day: 3).populations.sum(:size)
            end)
        end

        it 'correct healthy population' do
          expect { perform }
            .not_to(change do
              contagion.reload.instants.find_by(day: 3)
                       .populations.healthy.sum(:size)
            end)
        end

        it 'kills population' do
          perform

          expect(
            contagion.reload.instants.find_by(day: 3)
            .populations.dead.find_by(days: 0).size
          ).to eq(6)
        end

        it 'marks instant as ready' do
          expect { perform }
            .to change { contagion.reload.instants.find_by(day: 3).status }
            .to Simulation::Contagion::Instant::READY
        end
      end
    end

    context 'when an instant misses population with 0 days' do
      include_context 'with instant complete', 0
      include_context 'with instant complete', 1
      include_context 'with instant incomplete', 2
      include_context 'with instant incomplete', 3

      before do
        simulation
        Simulation::Contagion::Population.where(days: 0).delete_all
      end

      context 'when passing day 2' do
        let(:day) { 2 }

        it do
          expect { perform }.not_to raise_error
        end
      end
    end
  end
end

