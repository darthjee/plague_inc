# frozen_string_literal: true

class CreateSimulationContagionInstant < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_contagion_instants do |t|
      t.bigint :contagion_id, null: false
      t.bigint :current_population_id
      t.integer :day, null: false
      t.string :status, default: :created, null: false
      t.timestamps

      t.index %i[contagion_id day], unique: true
      t.foreign_key :simulation_contagions, column: :contagion_id
    end
  end
end
