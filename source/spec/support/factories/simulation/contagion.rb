# frozen_string_literal: true

FactoryBot.define do
  factory :contagion, class: 'Simulation::Contagion' do
    simulation            { build(:simulation, settings: nil) }
    lethality             { 0.5 }
    days_till_recovery    { 10 }
    days_till_sympthoms   { 10 }
    days_till_start_death { 10 }

    behaviors { build_list(:contagion_behavior, 1, contagion: @instance) }

    groups do
      build_list(
        :contagion_group, 1,
        contagion: @instance,
        behavior: behaviors.first
      )
    end
  end
end
