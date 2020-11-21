# frozen_string_literal: true

class MergePopulations < Sinclair::Options
  include Processor

  with_options :state

  def process
    instants.find_each do |instant|
      InstantProcessor.process(instant: instant, state: state)
    end
  end

  private

  def instants
    @instants ||= Simulation::Contagion::Instant
  end
end
