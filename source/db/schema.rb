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

ActiveRecord::Schema.define(version: 2021_08_18_230451) do

  create_table "simulation_contagion_behaviors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "contagion_id", null: false
    t.integer "interactions", null: false
    t.float "contagion_risk", null: false
    t.string "reference", limit: 10
    t.string "name"
    t.index ["contagion_id"], name: "fk_rails_2f5e4f0f2a"
    t.index ["reference", "contagion_id"], name: "contagion_behaviors_reference_contagion_id", unique: true
  end

  create_table "simulation_contagion_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "contagion_id", null: false
    t.float "lethality_override"
    t.integer "size", null: false
    t.string "reference", limit: 10
    t.integer "behavior_id", null: false
    t.integer "infected", default: 0, null: false
    t.index ["behavior_id"], name: "fk_rails_31dbcf6ede"
    t.index ["contagion_id"], name: "fk_rails_feaa742918"
    t.index ["reference", "contagion_id"], name: "index_simulation_contagion_groups_on_reference_and_contagion_id", unique: true
  end

  create_table "simulation_contagion_instants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "contagion_id", null: false
    t.bigint "current_population_id"
    t.integer "day", null: false
    t.string "status", default: "created", null: false
    t.index ["contagion_id", "day"], name: "index_simulation_contagion_instants_on_contagion_id_and_day", unique: true
    t.index ["current_population_id"], name: "fk_rails_e6877570cd"
  end

  create_table "simulation_contagion_populations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "instant_id", null: false
    t.integer "group_id", null: false
    t.integer "behavior_id", null: false
    t.integer "size", default: 0, null: false
    t.string "state", null: false
    t.integer "days", limit: 2, default: 0, null: false
    t.integer "interactions", default: 0, null: false
    t.integer "new_infections", default: 0, null: false
    t.index ["behavior_id"], name: "fk_rails_8cc87c0981"
    t.index ["group_id"], name: "fk_rails_ab58ee1256"
    t.index ["instant_id", "group_id", "state", "days"], name: "simulation_contagion_unique_keys", unique: true
  end

  create_table "simulation_contagions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.float "lethality", null: false
    t.integer "days_till_recovery", null: false
    t.integer "days_till_sympthoms", null: false
    t.integer "days_till_start_death", null: false
    t.integer "days_till_contagion", default: 0, null: false
    t.integer "days_till_immunization_end"
    t.index ["simulation_id"], name: "index_simulation_contagions_on_simulation_id", unique: true
  end

  create_table "simulation_graph_plots", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "label", null: false
    t.string "metric", limit: 7, null: false
    t.bigint "graph_id", null: false
    t.bigint "simulation_id", null: false
    t.string "field", limit: 8, null: false
    t.string "field_modifier"
    t.index ["graph_id"], name: "fk_rails_985da59b63"
    t.index ["simulation_id"], name: "fk_rails_37bab834ce"
  end

  create_table "simulation_graphs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "title"
  end

  create_table "simulations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "algorithm", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "created", null: false
    t.boolean "checked", default: false, null: false
  end

  create_table "simulations_tags", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.bigint "tag_id", null: false
    t.index ["simulation_id", "tag_id"], name: "index_simulations_tags_on_simulation_id_and_tag_id", unique: true
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  add_foreign_key "simulation_contagion_behaviors", "simulation_contagions", column: "contagion_id"
  add_foreign_key "simulation_contagion_groups", "simulation_contagion_behaviors", column: "behavior_id"
  add_foreign_key "simulation_contagion_groups", "simulation_contagions", column: "contagion_id"
  add_foreign_key "simulation_contagion_instants", "simulation_contagion_populations", column: "current_population_id"
  add_foreign_key "simulation_contagion_instants", "simulation_contagions", column: "contagion_id"
  add_foreign_key "simulation_contagion_populations", "simulation_contagion_behaviors", column: "behavior_id"
  add_foreign_key "simulation_contagion_populations", "simulation_contagion_groups", column: "group_id"
  add_foreign_key "simulation_contagion_populations", "simulation_contagion_instants", column: "instant_id"
  add_foreign_key "simulation_contagions", "simulations"
  add_foreign_key "simulation_graph_plots", "simulation_graphs", column: "graph_id"
  add_foreign_key "simulation_graph_plots", "simulations"
end
