# frozen_string_literal: true

class CreateSimulationTags < ActiveRecord::Migration[5.2]
  def change
    create_join_table :simulations, :tags do |t|
      t.index %i[simulation_id tag_id], unique: true
    end
  end
end
