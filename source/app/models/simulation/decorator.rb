# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Decorator < Azeroth::Decorator
    expose :id
    expose :name
  end
end

