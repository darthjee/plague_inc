# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation::Contagion, type: :model do
  subject(:contagion) { build(:contagion) }

  describe 'validations' do
    it do
      expect(contagion).to validate_presence_of(:simulation)
    end

    it do
      expect(contagion).to validate_presence_of(:lethality)
    end

    it do
      expect(contagion).to validate_presence_of(:days_till_recovery)
    end

    it do
      expect(contagion).to validate_presence_of(:days_till_sympthoms)
    end

    it do
      expect(contagion).to validate_presence_of(:days_till_start_death)
    end

    it do
      expect(contagion).to validate_inclusion_of(:lethality)
        .in_range((0.0..1.0))
    end

    it do
      expect(contagion).to validate_numericality_of(:days_till_recovery)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(contagion).to validate_numericality_of(:days_till_sympthoms)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(contagion).to validate_numericality_of(:days_till_start_death)
        .is_greater_than_or_equal_to(0)
    end

    context 'when days_till_sympthoms is bigger than days_till_recovery' do
      subject(:contagion) do
        build(:contagion,
              days_till_sympthoms: 11,
              days_till_recovery: 10)
      end

      it { expect(contagion).to be_invalid }

      it do
        contagion.valid?
        expect(contagion)
          .to have(1)
          .errors_on(:days_till_sympthoms)
      end
    end

    context 'when days_till_start_death is bigger than days_till_recovery' do
      subject(:contagion) do
        build(:contagion,
              days_till_start_death: 11,
              days_till_recovery: 10)
      end

      it { expect(contagion).to be_invalid }

      it do
        contagion.valid?
        expect(contagion)
          .to have(1)
          .errors_on(:days_till_start_death)
      end
    end
  end
end
