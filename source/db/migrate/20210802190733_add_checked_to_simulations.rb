class AddCheckedToSimulations < ActiveRecord::Migration[5.2]
  def change
    change_table :simulations do |t|
      t.boolean :checked, null: false, default: false
    end
  end
end
