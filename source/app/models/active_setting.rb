# frozen_string_literal: true

class ActiveSetting < ApplicationRecord
  validates :key,
            presence: true,
            length: { maximum: 50 },
            uniqueness: true,
            format: { with: /\A[a-z_][a-z0-9_]*\Z/ }
  validates :value,
            presence: true,
            length: { maximum: 255 }

  class << self
    def value_for(key)
      return unless key

      find_by(key: convert_key(key))&.value
    end

    def convert_key(key)
      return unless key

      key.to_s.downcase
    end
  end

  def key=(key)
    super(self.class.convert_key(key))
  end
end
