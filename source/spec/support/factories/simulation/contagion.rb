# frozen_string_literal: true

FactoryBot.define do
  factory :contagion, class: 'Simulation::Contagion' do
    simulation { build(:simulation, settings: nil, status: status) }

    lethality                  { 0.5 }
    days_till_recovery         { 10 }
    days_till_sympthoms        { 10 }
    days_till_start_death      { 10 }
    days_till_immunization_end { 90 }

    behaviors { build_list(:contagion_behavior, 1, contagion: @instance) }

    groups do
      build_list(
        :contagion_group, 1,
        contagion: @instance,
        behavior: behaviors.first,
        size: size
      )
    end

    transient do
      size { 100 }
      status { :created }
    end
  end
end
