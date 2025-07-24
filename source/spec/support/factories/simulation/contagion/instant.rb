# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_instant, class: 'Simulation::Contagion::Instant' do
    contagion { build(:contagion) }
    day       { 0 }
    status    { Simulation::Contagion::Instant::CREATED }

    trait :ready do
      status { Simulation::Contagion::Instant::READY }
    end

    trait :processing do
      status { Simulation::Contagion::Instant::PROCESSING }
    end

    trait :processed do
      status { Simulation::Contagion::Instant::PROCESSED }
    end

    trait :created do
      status { Simulation::Contagion::Instant::CREATED }
    end
  end
end
