# frozen_string_literal: true

class AddSizeToGroups < ActiveRecord::Migration[5.2]
  def up
    change_table :simulation_contagion_groups do |t|
      t.integer :size, null: false, default: 100
      t.change :size, :integer, null: false, default: nil
      t.change :contagion_id, :bigint, null: false, size: 20

      t.foreign_key :simulation_contagions, column: :contagion_id
    end
  end

  def down
    remove_foreign_key :simulation_contagion_groups, :simulation_contagions

    change_table :simulation_contagion_groups do |t|
      t.change :contagion_id, :integer, null: false
      t.remove :size
    end
  end
end
