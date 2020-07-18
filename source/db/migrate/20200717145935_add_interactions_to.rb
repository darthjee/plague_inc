# frozen_string_literal: true

class AddInteractionsTo < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_populations do |t|
      t.integer :interactions, null: false
    end
  end
end
