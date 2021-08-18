# frozen_string_literal: true

class ChangeIntegerSize < ActiveRecord::Migration[5.2]
  TABLE = :simulation_contagion_populations
  SIZES = {
    days: 1,
    size: 3,
    new_infections: 3
  }.freeze
  DEFAULTS = {
    default: 0,
    null: false
  }.freeze

  def up
    SIZES.each do |column, size|
      change_column TABLE, column, :integer, limit: size, **DEFAULTS
    end
  end

  def down
    SIZES.each_key do |column|
      change_column TABLE, column, :integer, **DEFAULTS
    end
  end
end
