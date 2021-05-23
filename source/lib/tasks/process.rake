# frozen_string_literal: true

desc 'Process unprocessed simulations'
task process: :environment do
  Simulation::Processor::All.process
end
