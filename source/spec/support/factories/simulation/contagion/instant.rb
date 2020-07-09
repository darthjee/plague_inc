# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_instant, class: 'Simulation::Contagion::Instant' do
    contagion { build(:contagion) }
    day       { 0 }
    status    { :created }
  end
end
