# frozen_string_literal: true

class IncreaseSizeOfPopulationInteractions < ActiveRecord::Migration[7.2]
  def up
    change_column :simulation_contagion_populations,
                  :interactions, :bigint,
                  default: 0, null: false
  end

  def down
    change_column :simulation_contagion_populations,
                  :interactions, :integer,
                  limit: 4, default: 0, null: false
  end
end
