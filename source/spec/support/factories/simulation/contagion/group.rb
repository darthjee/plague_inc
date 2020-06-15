# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_group, class: 'Simulation::Contagion::Group' do
    sequence(:name) { |n| "Group##{n}" }
    size            { 100 }
    reference       { SecureRandom.hex(5) }
    contagion       { build(:contagion, groups: []) }
  end
end
