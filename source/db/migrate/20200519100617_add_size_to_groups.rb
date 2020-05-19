# frozen_string_literal: true

class AddSizeToGroups < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_groups do |t|
      t.integer :size, null: false, default: 100
      t.change :size, :integer, null: false
    end
  end
end
