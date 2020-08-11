class AddStatusToSimulations < ActiveRecord::Migration[5.2]
  def change
    change_table :simulations do |t|
      t.string :status, default: :created, null: false
    end
  end
end
