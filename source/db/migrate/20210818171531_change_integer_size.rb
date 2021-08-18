class ChangeIntegerSize < ActiveRecord::Migration[5.2]
  TABLE = :simulation_contagion_populations

  def up
    change_column TABLE, :days, :integer, default: 0, null: false, limit: 1 
    change_column TABLE, :size, :integer, default: 0, null: false, limit: 3
    change_column TABLE, :new_infections, :integer, default: 0, null: false, limit: 3
  end

  def down
    change_column TABLE, :days, :integer, default: 0, null: false
    change_column TABLE, :size, :integer, default: 0, null: false
    change_column TABLE, :new_infections, :integer, default: 0, null: false
  end
end
