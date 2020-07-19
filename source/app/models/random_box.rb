class RandomBox
  def method_missing(_, *args)
    Random.rand(*args)
  end

  def respond_to_missing?(*args)
    true
  end
end
