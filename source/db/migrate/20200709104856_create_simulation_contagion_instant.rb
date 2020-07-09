# frozen_string_literal: true

class CreateSimulationContagionInstant < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_contagion_instants do |t|
      t.bigint :contagion_id, null: false
      t.bigint :current_population_id
      t.integer :day, null: false
      t.string :status, default: :created, null: false
      t.timestamps

      t.index [:contagion_id, :day], unique: true
      t.foreign_key :simulation_contagions, column: :contagion_id
    end

    create_table :simulation_contagion_populations do |t|
      t.bigint :instant_id, null: false
      t.bigint :group_id, null: false
      t.bigint :behavior_id, null: false
      t.integer :infected_days
      t.timestamps

      t.index [:instant_id, :group_id, :infected_days],
              name: :simulation_contagion_unique,
              unique: true
      t.foreign_key :simulation_contagion_instants,
                    column: :instant_id
      t.foreign_key :simulation_contagion_groups,
                    column: :group_id
      t.foreign_key :simulation_contagion_behaviors,
                    column: :behavior_id
    end

    add_foreign_key :simulation_contagion_instants,
                    :simulation_contagion_populations,
                    column: :current_population_id
  end
end
