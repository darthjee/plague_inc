# frozen_string_literal: true

shared_context 'with contagion cache', :contagion_cache do
  let(:cache_factory) do
    Cache::Factory.new.tap do |factory|
      factory.add_cache(Simulation::Contagion::Group)
      factory.add_cache(Simulation::Contagion::Behavior)
    end
  end

  let(:cache) { cache_factory.build }
end
