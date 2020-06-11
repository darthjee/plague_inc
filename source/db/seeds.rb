# frozen_string_literal: true

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
        size: 100,
      }],
      behaviors: [{
        interactions: 15,
        contagion_risk: 0.5,
      }]
    }
  }
)

Simulation::Builder.new(params, Simulation.all).build.save
