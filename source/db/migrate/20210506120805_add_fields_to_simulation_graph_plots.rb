# frozen_string_literal: true

class AddFieldsToSimulationGraphPlots < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_graph_plots do |t|
      t.bigint :simulation_id, null: false
      t.foreign_key :simulations, column: :simulation_id
    end
  end
end
