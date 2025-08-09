# frozen_string_literal: true

class Session < ApplicationRecord
  scope :active, -> { where('expiration IS NULL OR expiration > ?', Time.now) }

  belongs_to :user

  before_create :start_token

  private

  def start_token
    10.times do
      self.token = SecureRandom.base64(48)
      break unless self.class.where(token:).any?
    end
  end
end
