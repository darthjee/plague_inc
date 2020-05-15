# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Decorator < ::Decorator
    expose :id
    expose :name
    expose :algorithm
    expose :errors, if: :invalid?
  end
end
