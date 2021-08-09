# frozen_string_literal: true

require 'spec_helper'

describe Simulation::ProcessorCriticalWorker, :contagion_cache do
  it_behaves_like 'a processor worker'
end
