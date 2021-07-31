# frozen_string_literal: true

class Tag < ApplicationRecord
  before_save :downcase!

  validates :name,
            presence: true,
            length: { maximum: 50 }

  def self.for(name)
    find_or_initialize_by(name: name.downcase)
  end

  private

  def downcase!
    name.downcase!
  end
end
