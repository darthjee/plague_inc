class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    validates_presence_of :name
  end
end
