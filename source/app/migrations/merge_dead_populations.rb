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
    MergeGroup.process(
      populations: populations,
      group_id: group_id,
      size: size
    )
  end
end
