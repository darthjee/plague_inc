module SummaryDecorator
  module ClassMethods
    def expose_counts(state)
      send(:expose, state)
      send(:expose, "#{state}_percentage")

      Builder.new(self, state).tap do |builder|
        builder.add_methods(state)
      end.tap(&:build)
    end
  end
end

