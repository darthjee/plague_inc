# frozen_string_literal: true

FactoryBot.define do
  factory :simulation, class: 'Simulation' do
    sequence(:name) { |n| "Simulation ###{n}" }
    algorithm       { 'contagion' }
    contagion       { build(:contagion, simulation: nil) }
    created_at      { 2.days.ago }
    updated_at      { 1.days.ago }
  end

  trait :processing do
    status { :processing }
  end

  trait :processed do
    status { :processed }
  end

  trait :finished do
    status { :finished }
  end
end
