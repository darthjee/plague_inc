# frozen_string_literal: true

module SummaryDecorator
  module ClassMethods
    def counts_exposed
      @counts_exposed ||= []
    end

    def expose_counts(*states)
      Builder.new(self).tap do |builder|
        states.each do |state|
          builder.expose_all(state)
          builder.add_methods(state)
        end
      end.tap(&:build)
    end
  end
end
