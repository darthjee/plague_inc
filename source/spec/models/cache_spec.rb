# frozen_string_literal: true

require 'spec_helper'

fdescribe Cache do
  subject(:cache) { described_class.new(configs) }
  
  let(:configs) { Set.new(classes) }
  let(:classes) do
    [
      Simulation::Contagion::Group,
      Simulation::Contagion::Behavior,
    ]
  end

  describe '[]' do
    context 'when class has been set' do
      context 'when key is the class' do
        let(:key) { Simulation::Contagion::Group }

        it do
          expect(cache[key]).to be_a(CacheStore)
        end
      end

      context 'when key is the class' do
        let(:key) { :group }

        it do
          expect(cache[key]).to be_a(CacheStore)
        end
      end
    end

    context 'when class has not been set' do
      context 'when key is the class' do
        let(:key) { Simulation::Contagion }

        it do
          expect(cache[key]).to be_nil
        end
      end

      context 'when key is the class' do
        let(:key) { :contagion }

        it do
          expect(cache[key]).to be_nil
        end
      end
    end
  end
end

