# frozen_string_literal: true

namespace :populate do
  desc 'Populate all that needs populating'
  task all: :environment do
    Rake::Task['populate:reference'].invoke
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
end
