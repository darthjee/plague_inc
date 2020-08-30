# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Processor
    class Options < Sinclair::Options
      with_options times: 1
    end
  end
end
