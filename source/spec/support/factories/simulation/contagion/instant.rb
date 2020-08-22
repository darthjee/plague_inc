# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_instant, class: 'Simulation::Contagion::Instant' do
    contagion { build(:contagion) }
    day       { 0 }
    status    { Simulation::Contagion::Instant::CREATED }

    trait :ready do
      status { Simulation::Contagion::Instant::READY }
    end
  end
end
