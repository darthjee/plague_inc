class IncreaseSizeOfGroupsSize < ActiveRecord::Migration[7.2]
  def up
    change_column :simulation_contagion_groups,
                  :size, :bigint,
                  null: false
  end

  def down
    change_column :simulation_contagion_groups,
                  :size, :integer,
                  limit: 4, null: false
  end
end