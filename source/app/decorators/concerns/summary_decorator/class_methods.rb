module SummaryDecorator
  module ClassMethods
    def expose_counts(*states)

      Builder.new(self).tap do |builder|
        states.each do |state|
          send(:expose, state)
          send(:expose, "#{state}_percentage")
          builder.add_methods(state)
        end
      end.tap(&:build)
    end
  end
end

