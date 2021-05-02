class CreateSimulationGraph < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_graphs do |t|
      t.string :name, null: false
    end
  end
end
