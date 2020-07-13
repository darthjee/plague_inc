class AddDaysToPopulation < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_populations do |t|
      t.integer :days, null: false, default: 0
    end
  end
end
