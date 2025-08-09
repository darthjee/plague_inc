# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.bigint :user_id, null: false
      t.datetime :expiration
      t.string :token, limit: 64, null: false

      t.index :token, unique: true
    end

    add_foreign_key :sessions, :users
  end
end
