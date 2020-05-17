# frozen_string_literal: true

require 'spec_helper'

describe Simulation::SettingsBuilder do
  describe '#build' do
    subject(:builder) { described_class.new(simulation, parameters) }

    let(:simulation) { build(:simulation, settings: nil) }
    let(:params)     {}
    let(:parameters) { ActionController::Parameters.new(params) }
  end
end
