# frozen_string_literal: true

FactoryBot.define do
  factory :simulation_graph_plot, class: 'Simulation::Graph::Plot' do
    graph { build(:simulation_graph) }

    sequence(:label) { |n| "Plot ###{n}" }
    field            { 'dead' }
    metric           { 'value' }
  end
end
