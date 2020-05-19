class AddSizeToGroups < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_groups do |t|
      t.integer :size, null: false
    end
  end
end
