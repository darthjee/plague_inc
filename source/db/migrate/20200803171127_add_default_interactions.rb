# frozen_string_literal: true

class AddDefaultInteractions < ActiveRecord::Migration[5.2]
  def up
    change_column(
      :simulation_contagion_populations,
      :interactions, :integer,
      default: 0, null: false
    )
  end

  def down
    change_column(
      :simulation_contagion_populations,
      :interactions, :integer,
      default: nil, null: false
    )
  end
end
