# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Simulation instant
    class Instant < ApplicationRecord
      CREATED    = 'created'
      READY      = 'ready'
      PROCESSING = 'processing'
      PROCESSED  = 'processed'
      FINISHED   = 'finished'

      STATUSES = [
        CREATED, READY, PROCESSING, PROCESSED, FINISHED
      ].freeze

      scope :created,    -> { where(status: CREATED) }
      scope :ready,      -> { where(status: READY) }
      scope :processing, -> { where(status: PROCESSING) }

      belongs_to :contagion
      belongs_to :current_population,
                 optional: true,
                 class_name: 'Population'

      has_many :populations, autosave: true

      validates_presence_of :contagion

      validates :day,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  less_than: 2147483648  # limite do INT no MySQL
                }
      validates :status,
                presence: true,
                inclusion: { in: STATUSES }

      def processed?
        status == PROCESSED
      end

      def processing?
        status == PROCESSING
      end

      def created?
        status == CREATED
      end

      def ready?
        status == READY
      end
    end
  end
end
