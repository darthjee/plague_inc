class Decorator < Azeroth::Decorator
  expose :errors, if: :invalid?

  def invalid?
    object.errors.any?
  end

  def errors
    object.errors.messages
  end
end
