# frozen_string_literal: true

return if ENV['RACK_ENV'] == 'production'

params = ActionController::Parameters.new(
  simulation: {
    name: 'My Simulation',
    algorithm: 'contagion',
    settings: {
      lethality: 0.5,
      days_till_recovery: 13,
      days_till_sympthoms: 12,
      days_till_start_death: 11,
      groups: [{
        name: 'Group 1',
        size: 5000,
        behavior: 'behavior',
        reference: 'group',
        infected: 1
      }],
      behaviors: [{
        name: 'Behavior',
        interactions: 15,
        contagion_risk: 0.5,
        reference: 'behavior'
      }]
    }
  }
)

Simulation::Builder.process(params, Simulation.all).save
