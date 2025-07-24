# frozen_string_literal: true

class CreateActiveSetting < ActiveRecord::Migration[7.0]
  def change
    create_table :active_settings do |t|
      t.string :key, null: false, limit: 50
      t.string :value, null: false, limit: 255

      t.timestamps

      t.index :key, unique: true
    end
  end
end
