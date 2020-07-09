# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      belongs_to :instant
      belongs_to :group
      belongs_to :behavior

      validates_presence_of :instant, :group, :behavior
    end
  end
end
