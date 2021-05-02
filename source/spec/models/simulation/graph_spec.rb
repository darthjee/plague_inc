# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Graph, type: :model do
  subject(:simulation) { build(:simulation_graph) }

  describe 'validations' do
    it do
      expect(simulation).to validate_presence_of(:name)
    end

    it do
      expect(simulation).to validate_length_of(:name)
        .is_at_most(255)
    end
  end
end
