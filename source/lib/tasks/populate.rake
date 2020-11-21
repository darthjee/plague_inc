# frozen_string_literal: true

namespace :populate do
  desc 'Populate all that needs populating'
  task all: :environment do
    # Rake::Task['populate:merge_populations'].invoke
  end

  desc 'Merge immune populations'
  task merge_populations: :environment do
    MergePopulations.process(state: :immunue)
  end
end
