# frozen_string_literal: true

FactoryBot.define do
  factory :simulation_graph_plot, class: 'Simulation::Graph::Plot' do
    graph      { build(:simulation_graph) }
    simulation { build(:simulation) }

    sequence(:label) { |n| "Plot ###{n}" }
    field            { 'dead' }
    metric           { 'value' }

    transient do
      function { nil }
    end

    after(:create) do |plot, evaluator|
      return unless evaluator.function
      simulation = plot.simulation
      contagion = simulation.contagion
      group = contagion.groups.first
      function = evaluator.function

      contagion.instants.each do |instant|
        day = instant.day
        day.times do |days|
          create(
            :contagion_population,
            days: days,
            instant: instant,
            group: group,
            state: plot.field,
            size: function.calculate(day, days).to_i
          )
        end
      end
    end
  end
end
