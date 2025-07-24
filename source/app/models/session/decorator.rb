# frozen_string_literal: true

class Session < ApplicationRecord
  class Decorator < Azeroth::Decorator
    expose :expiration
    expose :token
    expose :errors, if: :invalid?
  end
end
