class CreateSimulationGraphPlots < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_graph_plots do |t|
      t.string :label, null: false
      t.string :field, null: false
      t.string :metric, null: false
    end
  end
end
