# frozen_string_literal: true

class MergePopulations
  include Processor

  def process
    instants.find_each do |instant|
      InstantProcessor.process(instant: instant)
    end
  end

  private

  def instants
    @instants ||= Simulation::Contagion::Instant
  end
end
