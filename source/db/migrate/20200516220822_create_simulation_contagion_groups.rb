# frozen_string_literal: true

class CreateSimulationContagionGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_contagion_groups do |t|
      t.string :name, null: false
      t.integer :contagion_id, null: false
      t.float :lethality_override
    end
  end
end
