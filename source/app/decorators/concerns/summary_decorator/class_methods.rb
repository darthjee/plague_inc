module SummaryDecorator
  module ClassMethods
    def expose_counts(state)
      send(:expose, state)
      send(:expose, "#{state}_percentage")

      Builder.new(self, state).tap do |builder|
        builder.add_count(state)
        builder.add_percentage(state)
      end.tap(&:build)
    end
  end
end

