class ChangeContagionPopulationsDefaultSize < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagion_populations do |t|
      t.change_default :size, 0
    end
  end
end
