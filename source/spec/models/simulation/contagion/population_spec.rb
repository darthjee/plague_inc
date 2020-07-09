# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Population, type: :model do
  subject(:population) { build(:contagion_population) }

  describe 'validations' do
    it do
      expect(population).to validate_presence_of(:instant)
    end

    it do
      expect(population).to validate_presence_of(:group)
    end

    it do
      expect(population).to validate_presence_of(:behavior)
    end
  end
end
