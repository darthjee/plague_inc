# frozen_string_literal: true

module Processor
  extend ActiveSupport::Concern

  included do
    private_class_method :new

    def self.process(*args)
      new(*args).process
    end
  end

  def process
    raise 'Not implemented yet'
  end
end
