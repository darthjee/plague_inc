class CreateSimulationContagionBehaviors < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_contagion_behaviors do |t|
      t.bigint :contagion_id, null: false
      t.integer :interactions, null: false
      t.float :contagion_risk, null: false

      t.foreign_key :simulation_contagions, column: :contagion_id
    end
  end
end
