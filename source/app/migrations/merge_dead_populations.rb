# frozen_string_literal: true

class MergeDeadPopulations
  include Processor

  def process
    instants.find_each do |instant|
      process_populations(instant.populations.dead)
    end
  end

  def instants
    @instants ||= Simulation::Contagion::Instant
  end

  def process_populations(populations)
    populations.group(:group_id).sum(:size).each do |group_id, size|
      process_group(populations, group_id, size)
    end
  end

  def process_group(populations, group_id, size)
    ActiveRecord::Base.transaction do
      size = populations
        .where(group_id: group_id).sum(:size)
      populations
        .where(group_id: group_id)
        .where(days: 0)
        .update_all(size: size)
      populations
        .where(group_id: group_id)
        .where
        .not(days: 0)
        .delete_all
    end
  end
end
