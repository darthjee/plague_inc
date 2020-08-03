# frozen_string_literal: true

# Class responsible for generaing random numbers
#
# This makes mockings easier as all  methods called
# respond +Random.rand+ but you can controll mocking
# better by mocking individual methods
class RandomBox
  def self.instance
    @instance ||= new
  end

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
