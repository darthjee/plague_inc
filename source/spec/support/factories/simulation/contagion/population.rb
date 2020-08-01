# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_population, class: 'Simulation::Contagion::Population' do
    instant  { build(:contagion_instant) }
    group    { build(:contagion_group) }
    behavior { build(:contagion_behavior) }
    state    { Simulation::Contagion::Population::HEALTHY }
    size     { 100 }

    interactions do
      behavior&.interactions.to_i * size
    end

    trait :infected do
      state { Simulation::Contagion::Population::INFECTED }
    end

    trait :healthy do
      state { Simulation::Contagion::Population::HEALTHY }
    end

    trait :dead do
      state { Simulation::Contagion::Population::DEAD }
    end
  end
end
