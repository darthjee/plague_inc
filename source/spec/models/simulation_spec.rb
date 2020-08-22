# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation, type: :model do
  subject(:simulation) { build(:simulation) }

  describe 'validations' do
    it do
      expect(simulation).to validate_presence_of(:name)
    end

    it do
      expect(simulation).to validate_length_of(:name)
        .is_at_most(255)
    end

    it do
      expect(simulation).to validate_presence_of(:algorithm)
    end

    it do
      expect(simulation).to validate_inclusion_of(:algorithm)
        .in_array(described_class::ALGORITHMS)
    end

    it do
      expect(simulation).to validate_presence_of(:settings)
    end

    it do
      expect(simulation).to validate_presence_of(:status)
    end

    it do
      expect(simulation).to validate_inclusion_of(:status)
        .in_array(described_class::STATUSES)
    end
  end

  describe '#settings' do
    context 'when simulation has no settings at all' do
      subject(:simulation) { build(:simulation, contagion: nil) }

      it { expect(simulation.settings).to be_nil }
    end

    context 'when simulation has contagion' do
      subject(:simulation) { build(:simulation) }

      it { expect(simulation.settings).to be_a(Simulation::Contagion) }

      it { expect(simulation.settings).to eq(simulation.contagion) }
    end
  end

  describe '#settings=' do
    context 'when settings is a contagion' do
      let(:settings) { build(:contagion, simulation: nil) }

      it do
        expect { simulation.settings = settings }
          .to change(simulation, :contagion)
      end
    end
  end
end
