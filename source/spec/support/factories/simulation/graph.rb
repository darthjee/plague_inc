# frozen_string_literal: true

FactoryBot.define do
  factory :simulation_graph, class: 'Simulation::Graph' do
    sequence(:name) { |n| "Graph ###{n}" }
    title { "Graph Title" }
  end
end
