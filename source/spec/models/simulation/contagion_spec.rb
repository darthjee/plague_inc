# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation::Contagion, type: :model do
  subject(:contagion) { build(:contagion) }

  describe 'validations' do
    it do
      expect(contagion).to validate_presence_of(:simulation_id)
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
  end
end
