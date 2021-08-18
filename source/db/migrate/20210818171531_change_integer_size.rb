# frozen_string_literal: true

class ChangeIntegerSize < ActiveRecord::Migration[5.2]
  TABLE = :simulation_contagion_populations
  SIZES = {
    days: 2,
    size: 4,
    new_infections: 4
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
