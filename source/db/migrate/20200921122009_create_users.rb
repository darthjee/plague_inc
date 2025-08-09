# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, force: :cascade do |t|
      t.string :name,               null: false
      t.string :login,              null: false
      t.string :email,              null: false
      t.string :encrypted_password, null: false
      t.string :salt,               null: false
      t.boolean :admin,             null: false, default: false

      t.timestamps

      t.index :email, unique: true
      t.index :login, unique: true
    end
  end
end
