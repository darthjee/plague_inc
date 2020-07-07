# frozen_string_literal: true

namespace :populate do
  desc 'Populate all that needs populating'
  task all: :environment do
    Rake::Task['populate:reference'].invoke
    Rake::Task['populate:group_behavior'].invoke
    Rake::Task['populate:behavior_name'].invoke
  end

  desc 'Populate references in Groups and Behaviors'
  task reference: :environment do
    Simulation::Contagion::Group.where(reference: nil).find_each do |group|
      group.reference = SecureRandom.hex(5)
      group.save(validate: false)
    end

    Simulation::Contagion::Behavior.where(reference: nil).find_each do |behav|
      behav.reference = SecureRandom.hex(5)
      behav.save(validate: false)
    end
  end

  desc 'Populate Behavior in Groups'
  task group_behavior: :environment do
    Simulation::Contagion::Group.where(behavior_id: nil).find_each do |group|
      group.behavior = group.contagion.behaviors.first
      group.save(validate: false)
    end
  end

  desc 'Populate Name in Behavior'
  task behavior_name: :environment do
    Simulation::Contagion::Behavior.where(name: nil).find_each do |behav|
      behav.name = "Behave ##{behav.id}"
      behav.save(validate: false)
    end
  end
end
