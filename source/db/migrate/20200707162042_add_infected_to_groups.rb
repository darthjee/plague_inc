# frozen_string_literal: true

class AddInfectedToGroups < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_groups do |t|
      t.integer :infected, null: false, default: 0
    end
  end
end
