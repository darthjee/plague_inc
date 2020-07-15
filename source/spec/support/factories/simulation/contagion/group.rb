# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_group, class: 'Simulation::Contagion::Group' do
    sequence(:name) { |n| "Group##{n}" }
    size            { 100 }
    infected        { 2 }
    reference       { SecureRandom.hex(5) }
    contagion       { build(:contagion, groups: []) }

    trait :with_behavior do
      behavior do
        build(
          :contagion_behavior,
          contagion: @instance.contagion
        )
      end
    end
  end
end
