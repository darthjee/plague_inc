# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation, type: :model do
  subject(:simulation) { build(:simulation) }

  describe 'validations' do
    it do
      expect(simulation).to validate_presence_of(:name)
    end

    it do
      expect(simulation).to validate_presence_of(:algorithm)
    end

    it do
      expect(simulation).to validate_inclusion_of(:algorithm)
        .in_array(described_class::ALGORITHMS)
    end
  end
end
