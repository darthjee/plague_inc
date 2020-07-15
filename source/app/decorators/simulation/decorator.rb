# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Decorator < ::Decorator
    ALLOWED_ATTRIBUTES.each(&method(:expose))

    expose :id
    expose :settings
    expose :errors, if: :invalid?
  end
end
