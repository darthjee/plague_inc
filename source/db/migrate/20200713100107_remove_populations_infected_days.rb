# frozen_string_literal: true

class RemovePopulationsInfectedDays < ActiveRecord::Migration[5.2]
  def up
    change_table :simulation_contagion_populations do |t|
      t.remove :infected_days
      t.index %i[instant_id group_id state days],
              name: :simulation_contagion_unique_keys, unique: true
      t.remove_index name: :simulation_contagion_unique
    end
  end

  def down
    change_table :simulation_contagion_populations do |t|
      t.integer :infected_days
      t.index %i[instant_id group_id infected_days],
              name: :simulation_contagion_unique, unique: true
      t.remove_index name: :simulation_contagion_unique_keys
    end
  end
end
