# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Processor::Options do
  subject(:params_options) { described_class.new(params) }

  let(:options)        { described_class.new }

  let(:hash_options)   { described_class.new(hash) }

  let(:times)      { Random.rand(10..20) }
  let(:block_size) { Random.rand(1000..2000) }
  let(:params)     { ActionController::Parameters.new(hash) }
  let(:hash) do
    {
      times: times,
      interaction_block_size: block_size,
      invalid_key: 1
    }
  end

  describe '#times' do
    it 'returns default' do
      expect(options.times).to eq(1)
    end

    context 'when initialized with hash' do
      it 'returns given value' do
        expect(hash_options.times).to eq(times)
      end
    end

    context 'when initialized with params' do
      it 'returns given value' do
        expect(params_options.times).to eq(times)
      end
    end
  end

  describe '#interaction_block_size' do
    it 'returns default' do
      expect(options.interaction_block_size)
        .to eq(Settings.interaction_block_size)
    end

    context 'when initialized with hash' do
      it 'returns given value' do
        expect(hash_options.interaction_block_size)
          .to eq(block_size)
      end
    end

    context 'when initialized with params' do
      it 'returns given value' do
        expect(params_options.interaction_block_size)
          .to eq(block_size)
      end
    end
  end
end
