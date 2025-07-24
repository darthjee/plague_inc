# frozen_string_literal: true

class AddContagionPopulationSize < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_populations do |t|
      t.integer :size, default: 1, null: false
    end
  end
end
