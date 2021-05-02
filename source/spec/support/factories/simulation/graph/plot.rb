# frozen_string_literal: true

FactoryBot.define do
  factory :simulation_graph_plot, class: 'Simulation::Graph::Plot' do
    sequence(:label) { |n| "Plot ###{n}" }
    field            { 'death' }
    metric           { 'value' }
  end
end