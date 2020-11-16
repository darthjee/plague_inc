require 'spec_helper'

fdescribe Cacheable do
  subject(:cached) { cached_class.new }

  let(:cached_class) do
    Class.new.tap do |clazz|
      clazz.include Cacheable
      clazz.cache_for(klass)
    end
  end

  let(:klass) { Simulation }

  let(:simulation) { create(:simulation) }

  xit 'test something' do
  end
end
