# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_group, class: 'Simulation::Contagion::Group' do
    sequence(:name) { |n| "Group##{n}" }
    contagion
  end
end

