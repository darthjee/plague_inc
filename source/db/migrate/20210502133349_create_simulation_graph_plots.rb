# frozen_string_literal: true

class CreateSimulationGraphPlots < ActiveRecord::Migration[5.2]
  def change
    create_table :simulation_graph_plots do |t|
      t.string :label, null: false
      t.string :field, null: false, limit: 19
      t.string :metric, null: false, limit: 7
    end
  end
end
