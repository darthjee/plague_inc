# frozen_string_literal: true

namespace :populate do
  desc 'Populate all that needs populating'
  task all: :environment do
    # Rake::Task['populate:merge_populations'].invoke
  end

  desc 'Merge dead populations'
  task merge_populations: :environment do
    MergeDeadPopulations.process
  end
end
