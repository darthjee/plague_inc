# frozen_string_literal: true

require './app/models/simulation'

class Simulation < ApplicationRecord
  # {Simulation} decoraror
  class Decorator < ::ModelDecorator
    Simulation::ALLOWED_ATTRIBUTES.each(&method(:expose))

    expose :id
    expose :settings
    expose :status
    expose :errors, if: :invalid?
  end
end
