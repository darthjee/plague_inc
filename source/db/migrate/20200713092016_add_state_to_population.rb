# frozen_string_literal: true

class AddStateToPopulation < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_populations do |t|
      t.string :state, size: 9, null: false
    end
  end
end
