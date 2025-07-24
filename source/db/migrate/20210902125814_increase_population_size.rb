# frozen_string_literal: true

class IncreasePopulationSize < ActiveRecord::Migration[5.2]
  def up
    change_column :simulation_contagion_populations,
                  :size,
                  :integer,
                  default: 0,
                  limit: 5,
                  null: false
  end

  def down
    change_column :simulation_contagion_populations,
                  :size,
                  :integer,
                  default: 0,
                  null: false
  end
end
