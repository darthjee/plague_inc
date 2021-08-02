# frozen_string_literal: true

require 'spec_helper'

shared_context 'with instant incomplete' do |day|
  before do
    instant = create(:contagion_instant, day: day, contagion: contagion)

    create(
      :contagion_population, :infected,
      size: 2 * day + 2,
      instant: instant,
      group: group,
      days: 0
    )

    if day > 0
      create(
        :contagion_population, :dead,
        size: day,
        instant: instant,
        group: group,
        days: 0
      )
      create(
        :contagion_population, :immune,
        size: day,
        instant: instant,
        group: group,
        days: 0
      )
    end

    if day > 1
      create(
        :contagion_population, :dead,
        size: day - 1,
        instant: instant,
        group: group,
        days: 1
      )
      create(
        :contagion_population, :immune,
        size: day - 1,
        instant: instant,
        group: group,
        days: 1
      )
    end
  end
end

shared_context 'with instant complete' do |day|
  include_context 'with instant incomplete', day

  before do
    instant = contagion.reload.instants.find_by(day: day)

    create(
      :contagion_population, :healthy,
      size: size - instant.populations.sum(:size),
      instant: instant,
      group: group,
      new_infections: 2 * day + 4,
      days: day
    )
  end
end

fdescribe Simulation::Contagion::Reparator do
  let(:simulation_id) { simulation.id }
  let(:simulation)   { contagion.simulation }
  let(:size)         { 800 }
  let(:group)        { contagion.groups.first }
  let(:contagion) do
    create(
      :contagion,
      size: size,
      status: :finished,
      days_till_recovery: 1,
      days_till_sympthoms: 0,
      days_till_start_death: 1,
      lethality: 1
    )
  end

  describe '.check_all' do
    subject(:check_and_fix_all) do
      described_class.check_all
    end

    context "when instant is incomplete" do
      include_context 'with instant incomplete', 0

      it do
        expect { check_and_fix_all }
          .not_to change { simulation.reload.checked }
      end
    end

    context "when instant is complete" do
      include_context 'with instant complete', 0

      it do
        expect { check_and_fix_all }
          .to change { simulation.reload.checked }
          .from(false).to(true)
      end
    end
  end

  describe '.repair_all' do
    subject(:repair_all) do
      described_class.repair_all
    end

    before do
      allow(Simulation::ProcessorWorker)
        .to receive(:perform_async)
    end

    context 'when there is few incomplete instants' do
      include_context 'with instant incomplete', 0

      it do
        expect { repair_all }
          .to change { simulation.reload.status }
          .from(Simulation::FINISHED)
          .to(Simulation::CREATED)
      end

      it do
        repair_all

        expect(Simulation::ProcessorWorker)
          .to have_received(:perform_async)
          .with(simulation.id)
      end
    end

    context 'when there are several incomplete instants' do
      include_context 'with instant complete', 0
      include_context 'with instant complete', 1
      include_context 'with instant complete', 2
      include_context 'with instant incomplete', 3
      include_context 'with instant incomplete', 4

      it do
        expect { repair_all }
          .to change { simulation.reload.status }
          .from(Simulation::FINISHED)
          .to(Simulation::PROCESSED)
      end

      it do
        repair_all

        expect(Simulation::ProcessorWorker)
          .to have_received(:perform_async)
          .with(simulation.id)
      end
    end
  end

  xdescribe '.check_and_fix_all' do
    subject(:check_and_fix_all) do
      described_class.check_all
    end

    include_context 'with instant incomplete', 0

    it do
      expect { check_and_fix_all }
        .to change { simulation.reload.status }
        .from(Simulation::FINISHED)
        .to(Simulation::PROCESSED)
    end
  end

  describe '.process' do
    subject(:process) do
      described_class.process(simulation_id, day)
    end

    let(:day) { 0 }

    context 'when there is only one instant' do
      include_context 'with instant incomplete', 0

      it do
        expect { process }.to change { simulation.reload.status }
          .to(Simulation::CREATED)
      end

      it 'removes all instants' do
        expect { process }
          .to change { simulation.reload.contagion.instants.size }
          .to(0)
      end

      it 'removes populations' do
        expect { process }
          .to change(Simulation::Contagion::Population, :count)
          .by(-1)
      end
    end

    context 'when there are 2 instants instant' do
      let(:day) { 1 }

      include_context 'with instant complete', 0
      include_context 'with instant incomplete', 1

      it do
        expect { process }.to change { simulation.reload.status }
          .to(Simulation::CREATED)
      end

      it 'removes all instants' do
        expect { process }
          .to change { simulation.reload.contagion.instants.size }
          .to(0)
      end

      it 'removes populations' do
        expect { process }
          .to change(Simulation::Contagion::Population, :count)
          .by(-5)
      end
    end

    context 'when there are more than 2 instants instant' do
      include_context 'with instant complete', 0
      include_context 'with instant complete', 1
      include_context 'with instant incomplete', 2
      include_context 'with instant incomplete', 3

      context 'when passing day 0' do
        let(:day) { 0 }

        it do
          expect { process }.to change { simulation.reload.status }
            .to(Simulation::CREATED)
        end

        it 'removes all instants' do
          expect { process }
            .to change { simulation.reload.contagion.instants.size }
            .to(0)
        end

        it 'removes populations' do
          expect { process }
            .to change(Simulation::Contagion::Population, :count)
            .by(-16)
        end
      end

      context 'when passing day 1' do
        let(:day) { 1 }

        it do
          expect { process }.to change { simulation.reload.status }
            .to(Simulation::CREATED)
        end

        it 'removes all instants' do
          expect { process }
            .to change { simulation.reload.contagion.instants.size }
            .to(0)
        end

        it 'removes populations' do
          expect { process }
            .to change(Simulation::Contagion::Population, :count)
            .by(-16)
        end
      end

      context 'when passing day 2' do
        let(:day) { 2 }

        it do
          expect { process }.to change { simulation.reload.status }
            .to(Simulation::PROCESSED)
        end

        it 'Deletes only instants after the selected instant' do
          expect { process }
            .to change { simulation.reload.contagion.instants.size }
            .by(-1)
        end

        it 'removes populations of removed instants' do
          expect { process }
            .to change(Simulation::Contagion::Population, :count)
            .by(-4)
        end

        it 'correct populations size' do
          expect { process }
            .to change {
              contagion.instants.find_by(day: 2).populations.sum(:size)
            }
              .to(size)
        end

        it 'correct healthy population' do
          expect { process }
            .to change {
              contagion.reload.instants.find_by(day: 2)
                .populations.healthy.sum(:size)
            } .to(788)
        end

        it 'kills population' do
          process

          expect(
            contagion.reload.instants.find_by(day: 2)
            .populations.dead.find_by(days: 0).size
          ).to eq(4)
        end

        it 'marks instant as ready' do
          expect { process }
            .to change { contagion.reload.instants.find_by(day: 2).status }
            .to Simulation::Contagion::Instant::READY
        end
      end

      context 'when passing day 3' do
        let(:day) { 3 }

        it do
          expect { process }.to change { simulation.reload.status }
            .to(Simulation::PROCESSED)
        end

        it 'Deletes only instants after the selected instant' do
          expect { process }
            .not_to change { simulation.reload.contagion.instants.size }
        end

        it 'removes populations of removed instants' do
          expect { process }
            .not_to change(Simulation::Contagion::Population, :count)
        end

        it 'correct populations size' do
          expect { process }
            .not_to change {
              contagion.instants.find_by(day: 3).populations.sum(:size)
            }
        end

        it 'correct healthy population' do
          expect { process }
            .not_to change {
              contagion.reload.instants.find_by(day: 3)
                .populations.healthy.sum(:size)
            }
        end

        it 'kills population' do
          process

          expect(
            contagion.reload.instants.find_by(day: 3)
            .populations.dead.find_by(days: 0).size
          ).to eq(6)
        end

        it 'marks instant as ready' do
          expect { process }
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
          expect { process }.not_to raise_error
        end
      end
    end
  end
end
