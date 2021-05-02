# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    class Plot < ApplicationRecord
      validates_presence_of :label, :attribute, :metric
    end
  end
end
