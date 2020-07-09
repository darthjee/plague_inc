# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Contagion::Instant, type: :model do
  subject(:instant) { build(:contagion_instant) }

  describe 'validations' do
    it do
      expect(instant).to validate_presence_of(:contagion)
    end

    it do
      expect(instant).to validate_presence_of(:day)
    end

    it do
      expect(instant).to validate_presence_of(:status)
    end

    it do
      expect(instant).to validate_numericality_of(:day)
        .is_greater_than_or_equal_to(0)
    end
  end
end
