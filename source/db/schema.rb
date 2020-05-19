# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_19_100617) do

  create_table "simulation_contagion_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "contagion_id", null: false
    t.float "lethality_override"
    t.integer "size", default: 100, null: false
  end

  create_table "simulation_contagions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.float "lethality", null: false
    t.integer "days_till_recovery", null: false
    t.integer "days_till_sympthoms", null: false
    t.integer "days_till_start_death", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["simulation_id"], name: "index_simulation_contagions_on_simulation_id", unique: true
  end

  create_table "simulations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "algorithm", null: false
  end

  add_foreign_key "simulation_contagions", "simulations"
end
