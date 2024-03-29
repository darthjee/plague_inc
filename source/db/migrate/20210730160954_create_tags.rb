# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name, limit: 50, null: false
      t.index :name, unique: true
    end
  end
end
