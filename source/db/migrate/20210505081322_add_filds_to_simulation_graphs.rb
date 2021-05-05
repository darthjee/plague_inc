class AddFildsToSimulationGraphs < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_graphs do |t|
      t.string :title
    end
  end
end
