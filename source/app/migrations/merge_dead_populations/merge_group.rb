# frozen_string_literal: true

class MergeDeadPopulations
  class MergeGroup < Sinclair::Options
    include Processor
    
    with_options :populations, :group_id, :size

    def process
      ActiveRecord::Base.transaction do
        update_size
        delete_populations
      end
    end

    private

    def update_size
      base_scope
        .where(days: min_days)
        .update_all(size: size)
    end

    def delete_populations
      base_scope
        .where
        .not(days: min_days)
        .delete_all
    end

    def base_scope
      @base_scope ||= populations.where(group_id: group_id)
    end

    def min_days
      @min_days ||= base_scope.minimum(:days)
    end
  end
end
