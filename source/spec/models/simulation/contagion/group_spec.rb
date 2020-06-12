# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation::Contagion::Group, type: :model do
  subject(:group) { build(:contagion_group) }

  describe 'validations' do
    it do
      expect(group).to validate_presence_of(:contagion)
    end

    it do
      expect(group).not_to validate_presence_of(:behavior)
    end

    it do
      expect(group).to validate_presence_of(:name)
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
      expect(group).to validate_length_of(:reference)
        .is_at_most(10)
    end
  end
end
