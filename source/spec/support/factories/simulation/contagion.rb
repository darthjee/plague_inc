# frozen_string_literal: true

FactoryBot.define do
  factory :contagion, class: 'Simulation::Contagion' do
    simulation
    lethality             { 0.5 }
    days_till_recovery    { 10 }
    days_till_sympthoms   { 10 }
    days_till_start_death { 10 }
  end
end
