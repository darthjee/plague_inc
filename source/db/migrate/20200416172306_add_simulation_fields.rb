# frozen_string_literal: true

class AddSimulationFields < ActiveRecord::Migration[5.2]
  def change
    change_column :simulations, :name, :string, null: false, default: 'UNAMED'
    change_column :simulations, :name, :string, null: false, default: nil

    change_table :simulations do |t|
      t.string :algorithm, size: 10, null: false, default: :contagion
    end
    change_column :simulations, :algorithm,
                  :string, size: 10, null: false, default: nil
  end
end
