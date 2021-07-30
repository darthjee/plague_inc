class Tag < ApplicationRecord
  before_save :downcase!

  def downcase!
    name.downcase!
  end
end
