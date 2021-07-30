class Tag < ApplicationRecord
  before_save :downcase!

  def self.for(name)
    find_or_initialize_by(name: name.downcase)
  end

  private

  def downcase!
    name.downcase!
  end
end
