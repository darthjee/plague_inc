# frozen_string_literal: true

class AddDaysTillImmuizationEnd < ActiveRecord::Migration[5.2]
  def change
    change_table :simulation_contagions do |t|
      t.integer :days_till_immunization_end
    end
  end
end
