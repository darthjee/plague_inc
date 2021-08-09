# frozen_string_literal: true

require 'spec_helper'

describe Simulation::ProcessorInitialWorker, :contagion_cache do
  it_behaves_like 'a processor worker' do
    let(:next_worker) { Simulation::ProcessorWorker }
  end
end
