module SummaryDecorator
  module ClassMethods
    def expose_counts(state)
      send(:expose, state)
      send(:expose, "#{state}_percentage")

      Sinclair.new(self).tap do |builder|
        builder.add_method(state, cached: true) do
          scoped_size(state)
        end

        builder.add_method("#{state}_percentage") do
          return 0 unless total.positive?

          send(state).to_f / total
        end
      end.tap(&:build)
    end
  end
end

