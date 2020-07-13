# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_population, class: 'Simulation::Contagion::Population' do
    instant  { build(:contagion_instant) }
    group    { build(:contagion_group) }
    behavior { build(:contagion_behavior) }
    state    { :healthy }
    size     { 100 }
  end
end
