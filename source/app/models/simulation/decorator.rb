# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Decorator < Azeroth::Decorator
    expose :id
    expose :name
    expose :algorithm
    expose :errors, if: :invalid?

    def errors
      object.errors.messages
    end
  end
end
