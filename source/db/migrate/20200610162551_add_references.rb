# frozen_string_literal: true

class AddReferences < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_groups do |t|
      t.string :reference, size: 10
      t.index %i[reference contagion_id], unique: true
    end

    change_table :simulation_contagion_behaviors do |t|
      t.string :reference, size: 10
      t.index %i[reference contagion_id], unique: true, name: :contagion_behaviors_reference_contagion_id
    end
  end
end
