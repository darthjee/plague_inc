class CreateSimulationContagionInstant < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_contagion_instants do |t|
      t.integer :contagion_id, null: false
      t.integer :day, null: false
      t.string :status, default: :created, null: false
      t.integer :current_population_id
      t.timestamps
    end

    create_table :simulation_contagion_populations do |t|
      t.integer :instant_id, null: false
      t.integer :infected_days
      t.integer :group_id, null: false
      t.integer :behavior_id, null: false
      t.timestamps
    end
  end
end
