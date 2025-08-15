
module ConditionalWorker
  def perform(*args)
    return unless process?

    process(*args)
  end

  def process?
    Settings.background_worker
  end
end