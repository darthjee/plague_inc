# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Processor
    # @author darthjee
    #
    # Processing options
    #
    # Options available are:
    # - times Number of instants to be generated / processed
    # - interaction_block_size blocks of interactions to be processed between
    class Options < Sinclair::Options
      skip_validation

      with_options(
        times: Settings.processing_iteractions,
        interaction_block_size: Settings.interaction_block_size
      )
    end
  end
end
