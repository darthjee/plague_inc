# frozen_string_literal: true

class AddInitialBehavior < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_groups do |t|
      t.bigint :behavior_id
      t.foreign_key :simulation_contagion_behaviors, column: :behavior_id
    end
  end
end
