# frozen_string_literal: true

class MergePopulations
  class InstantProcessor < Sinclair::Options
    include Processor

    with_options :instant, :state

    def process
      grouped_populations.sum(:size).each do |group_id, size|
        MergeGroup.process(
          populations: populations,
          group_id: group_id,
          size: size
        )
      end
    end

    private

    def grouped_populations
      populations.group(:group_id)
    end

    def populations
      @populations ||= instant.populations.where(state: state)
    end
  end
end
