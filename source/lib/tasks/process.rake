# frozen_string_literal: true

desc 'Process unprocessed simulations'
task :process, [:simulation_id] => :environment do |_task, args|
  id = args[:simulation_id]
  Simulation::Processor::All.process(id)
end
