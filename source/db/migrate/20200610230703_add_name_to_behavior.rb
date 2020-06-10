# frozen_string_literal: true

class AddNameToBehavior < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_behaviors do |t|
      t.string :name
    end
  end
end
