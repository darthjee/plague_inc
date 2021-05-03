# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Graph, type: :model do
  subject(:graph) { build(:simulation_graph) }

  describe 'validations' do
    it do
      expect(graph).to validate_presence_of(:name)
    end

    it do
      expect(graph).to validate_length_of(:name)
        .is_at_most(255)
    end
  end
end
