class AddSimulationFields < ActiveRecord::Migration[5.2]
  def change
    change_table :simulations do |t|
      t.string :algorithm, size: 10, null: false, default: :infection
    end
  end
end
