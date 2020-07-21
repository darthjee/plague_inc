# frozen_string_literal: true

class AddNewInfectionsToPopulations < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_populations do |t|
      t.integer :new_infections, null: false, default: 0
    end
  end
end
