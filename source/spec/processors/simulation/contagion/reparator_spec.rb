# frozen_string_literal: true

require 'spec_helper'

shared_context 'with instant incomplete' do |day|
  before do
    instant = create(:contagion_instant, day: day, contagion: contagion)

    create(
      :contagion_population, :infected,
      size: size / 4,
      instant: instant,
      group: group,
      days: 0
    )

    if day > 0
      create(
        :contagion_population, :dead,
        size: size / 8,
        instant: instant,
        group: group,
        days: 0
      )
      create(
        :contagion_population, :immune,
        size: size / 8,
        instant: instant,
        group: group,
        days: 0
      )
    end

    if day > 1
      create(
        :contagion_population, :dead,
        size: size / 8,
        instant: instant,
        group: group,
        days: 1
      )
      create(
        :contagion_population, :immune,
        size: size / 8,
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
      group: group
    )
  end
end

fdescribe Simulation::Contagion::Reparator do
  subject(:process) { described_class.process(simulation_id, day) }

  let(:simulation_id) { simulation.id }
  let(:simulation)   { contagion.simulation }
  let(:contagion)    { create(:contagion, size: size, status: :finished) }
  let(:size)         { 800 }
  let(:group)        { contagion.groups.first }

  describe '.process' do
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

      context 'when passing day 0' do
        let(:day) { 0 }

        it do
          expect { process }.to change { simulation.reload.status }
            .to(Simulation::CREATED)
        end

        context 'when passing day 1' do
          let(:day) { 1 }

          it 'removes all instants' do
            expect { process }
              .to change { simulation.reload.contagion.instants.size }
              .to(0)
          end

          it 'removes populations' do
            expect { process }
              .to change(Simulation::Contagion::Population, :count)
              .by(-11)
          end
        end
      end

      context 'when passing day 1' do
        let(:day) { 1 }

        it do
          expect { process }.to change { simulation.reload.status }
            .to(Simulation::CREATED)
        end

        context 'when passing day 1' do
          let(:day) { 1 }

          it 'removes all instants' do
            expect { process }
              .to change { simulation.reload.contagion.instants.size }
              .to(0)
          end

          it 'removes populations' do
            expect { process }
              .to change(Simulation::Contagion::Population, :count)
              .by(-11)
          end
        end
      end

      context 'when passing day 2' do
        let(:day) { 2 }

        it do
          expect { process }.to change { simulation.reload.status }
            .to(Simulation::PROCESSED)
        end

        context 'when passing day 1' do
          let(:day) { 1 }

          it 'Does not remove any instant' do
            expect { process }
              .not_to change { simulation.reload.contagion.instants.size }
          end

          xit 'removes populations' do
            expect { process }
              .to change(Simulation::Contagion::Population, :count)
              .by(-11)
          end
        end
      end
    end
  end
end
