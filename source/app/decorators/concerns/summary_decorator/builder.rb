module SummaryDecorator
  class Builder < Sinclair
    def initialize(klass, state)
      @state = state
      super(klass)
    end

    def add_count(state)
      add_method(state, cached: true) do
        scoped_size(state)
      end
    end

    def add_percentage(state)
      add_method("#{state}_percentage") do
        return 0 unless total.positive?

        send(state).to_f / total
      end
    end

    private

    attr_reader :state
  end
end
