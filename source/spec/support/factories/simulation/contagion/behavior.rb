# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_behavior, class: 'Simulation::Contagion::Behavior' do
    interactions   { 15 }
    contagion_risk { 0.5 }
    reference      { SecureRandom.hex(5) }
    contagion
  end
end
