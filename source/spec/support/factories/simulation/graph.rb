# frozen_string_literal: true

FactoryBot.define do
  factory :simulation_graph, class: 'Simulation::Graph' do
    sequence(:name) { |n| "Simulation ###{n}" }
  end
end
