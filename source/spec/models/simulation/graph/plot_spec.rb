# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Graph::Plot, type: :model do
  subject(:simulation) { build(:simulation_graph_plot) }

  describe 'validations' do
    it do
      expect(simulation).to validate_presence_of(:label)
    end

    it do
      expect(simulation).to validate_length_of(:label)
        .is_at_most(255)
    end

    it do
      expect(simulation).to validate_presence_of(:attribute)
    end

    it do
      expect(simulation).to validate_length_of(:attribute)
        .is_at_most(255)
    end

    it do
      expect(simulation).to validate_presence_of(:metric)
    end

    it do
      expect(simulation).to validate_length_of(:metric)
        .is_at_most(255)
    end
  end
end
