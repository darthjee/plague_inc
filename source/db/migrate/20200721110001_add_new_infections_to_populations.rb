class AddNewInfectionsToPopulations < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagions do |t|
      t.integer :new_infections, null: false, default: 0
    end
  end
end
