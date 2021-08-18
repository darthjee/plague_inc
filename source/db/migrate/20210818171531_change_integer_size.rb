class ChangeIntegerSize < ActiveRecord::Migration[5.2]
  def up
    change_column :simulation_contagion_populations,
      :days, :integer, default: 0, null: false, limit: 1 
  end

  def down
    change_column :simulation_contagion_populations,
      :days, :integer, default: 0, null: false
  end
end
