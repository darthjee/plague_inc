# frozen_string_literal: true

class RandomBox
  delegate :rand, to: :Random

  delegate :>, :>=, :<, :<=, to: :rand

  # rubocop:disable Style/MethodMissingSuper
  def method_missing(_, *args)
    Random.rand(*args)
  end
  # rubocop:enable Style/MethodMissingSuper

  def respond_to_missing?(*_args)
    true
  end
end
