# frozen_string_literal: true

require 'spec_helper'

xdescribe Simulation::Contagion::Processor do
  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }

  describe '.process' do
    context 'when there are no instants' do
      it do
        expect { described_class.process(contagion) }
          .to change { contagion.reload.instants.count }
          .by(1)
      end
    end
  end
end
