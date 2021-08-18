# frozen_string_literal: true

class ChangeIntegerSize < ActiveRecord::Migration[5.2]
  TABLE = :simulation_contagion_populations
  DEFAULTS = {
    default: 0,
    null: false
  }.freeze

  def up
    change_column TABLE, :days, :integer, limit: 2, **DEFAULTS
  end

  def down
    change_column TABLE, :days, :integer, **DEFAULTS
  end
end
