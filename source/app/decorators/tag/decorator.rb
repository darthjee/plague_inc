# frozen_string_literal: true

class Tag < ApplicationRecord
  # {Tag} decorator
  class Decorator < ::ModelDecorator
    expose :name
  end
end