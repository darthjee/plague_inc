# frozen_string_literal: true

namespace :test do
  desc 'Test sidekiq'
  task sidekiq: :environment do
    Simulation.where.not(status: Simulation::FINISHED).pluck(:id).each do |id|
      Simulation::ProcessorWorker.perform_async(id)
    end

    puts Sidekiq::Queue.all.map { |q| [q.name, q.size] }.to_h
  end
end
