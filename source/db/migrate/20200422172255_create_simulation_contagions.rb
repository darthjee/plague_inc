# frozen_string_literal: true

class CreateSimulationContagions < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_contagions do |t|
      t.bigint :simulation_id, null: false
      t.float   :lethality, null: false
      t.integer :days_till_recovery, null: false
      t.integer :days_till_sympthoms, null: false
      t.integer :days_till_start_death, null: false

      t.timestamps

      t.index :simulation_id, unique: true
    end

    add_foreign_key :simulation_contagions, :simulations
  end
end
