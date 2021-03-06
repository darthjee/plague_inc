# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation::Contagion::Group, type: :model do
  subject(:group) { build(:contagion_group, behavior: behavior) }

  let(:behavior) { build(:contagion_behavior) }

  describe 'validations' do
    it do
      expect(group).to validate_presence_of(:contagion)
    end

    it do
      expect(group).to validate_presence_of(:reference)
    end

    it do
      expect(group).to validate_presence_of(:behavior)
    end

    it do
      expect(group).to validate_presence_of(:name)
    end

    it do
      expect(group).not_to validate_presence_of(:infected)
    end

    it do
      expect(group).to validate_length_of(:name)
        .is_at_most(255)
    end

    it do
      expect(group).to validate_numericality_of(:size)
        .is_greater_than_or_equal_to(1)
    end

    it do
      expect(group).to validate_numericality_of(:size)
        .only_integer
    end

    it do
      expect(group).to validate_numericality_of(:infected)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(group).to validate_numericality_of(:infected)
        .only_integer
    end

    it do
      expect(group).to validate_length_of(:reference)
        .is_at_most(10)
    end

    context 'when infected is the as big as size' do
      subject(:group) do
        build(:contagion_group, behavior: behavior, size: 10, infected: 10)
      end

      it { expect(group).to be_valid }
    end

    context 'when infected is bigger than size' do
      subject(:group) do
        build(:contagion_group, behavior: behavior, size: 10, infected: 11)
      end

      it { expect(group).to be_invalid }

      it do
        group.valid?
        expect(group)
          .to have(1)
          .errors_on(:infected)
      end
    end
  end

  describe 'healthy' do
    subject(:group) do
      build(:contagion_group, behavior: behavior, infected: infected, size: 100)
    end

    context 'when none are infected' do
      let(:infected) { 0 }

      it 'returns full size' do
        expect(group.healthy).to eq(100)
      end
    end

    context 'when some are infected' do
      let(:infected) { 10 }

      it 'returns partial size' do
        expect(group.healthy).to eq(90)
      end
    end

    context 'when all are infected' do
      let(:infected) { 100 }

      it do
        expect(group.healthy).to eq(0)
      end
    end
  end

  describe 'any_infected?' do
    subject(:group) do
      build(:contagion_group, behavior: behavior, infected: infected, size: 100)
    end

    context 'when none are infected' do
      let(:infected) { 0 }

      it { expect(group).not_to be_any_infected }
    end

    context 'when some are infected' do
      let(:infected) { 10 }

      it { expect(group).to be_any_infected }
    end

    context 'when all are infected' do
      let(:infected) { 100 }

      it { expect(group).to be_any_infected }
    end
  end

  describe 'any_healthy?' do
    subject(:group) do
      build(:contagion_group, behavior: behavior, infected: infected, size: 100)
    end

    context 'when none are infected' do
      let(:infected) { 0 }

      it { expect(group).to be_any_healthy }
    end

    context 'when some are infected' do
      let(:infected) { 10 }

      it { expect(group).to be_any_healthy }
    end

    context 'when all are infected' do
      let(:infected) { 100 }

      it { expect(group).not_to be_any_healthy }
    end
  end
end
