# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation::Contagion::Group, type: :model do
  subject(:group) { build(:contagion_group) }

  describe 'validations' do
    it do
      expect(group).to validate_presence_of(:contagion)
    end

    it do
      expect(group).to validate_presence_of(:name)
    end
  end
end
