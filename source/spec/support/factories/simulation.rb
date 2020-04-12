# frozen_string_literal: true

FactoryBot.define do
  factory :simulation, class: 'Simulation' do
    sequence(:name) { |n| "Simulation ###{n}" }
  end
end
