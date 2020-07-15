# frozen_string_literal: true

require './app/models/simulation'

class Simulation < ApplicationRecord
  class Decorator < ::Decorator
    Simulation::ALLOWED_ATTRIBUTES.each(&method(:expose))

    expose :id
    expose :settings
    expose :errors, if: :invalid?
  end
end
