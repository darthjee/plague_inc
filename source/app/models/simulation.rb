# frozen_string_literal: true

class Simulation < ApplicationRecord
  validates_presence_of :name, :algorithm
end
