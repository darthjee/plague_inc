class AddDaysTillContagion < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagions do |t|
      t.integer :days_till_contagion, null: false, default: 0
    end
  end
end
