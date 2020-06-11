namespace :reference do
  desc 'Populate references in Groups and Behaviors'
  task populate: :environment do
    Simulation::Contagion::Group.find_each do |group|
      group.update(reference: SecureRandom.hex(5))
    end

    Simulation::Contagion::Reference.find_each do |reference|
      reference.update(reference: SecureRandom.hex(5))
    end
  end
end
