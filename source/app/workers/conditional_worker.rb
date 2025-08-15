# frozen_string_literal: true

module ConditionalWorker
  def perform(*)
    return unless process?

    process(*)
  end

  def process?
    Settings.background_worker
  end
end
