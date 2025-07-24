# frozen_string_literal: true

class ResizeGroupId < ActiveRecord::Migration[5.2]
  def up
    with_fk do
      change_column :simulation_contagion_groups, :id, :integer,
                    null: false, unique: true, auto_increment: true
      change_column :simulation_contagion_populations, :group_id,
                    :integer, null: false
    end
  end

  def down
    with_fk do
      change_column :simulation_contagion_groups, :id, :bigint,
                    null: false, unique: true, auto_increment: true
      change_column :simulation_contagion_populations, :group_id, :bigint,
                    null: false
    end
  end

  private

  def with_fk
    remove_foreign_key :simulation_contagion_populations,
                       :simulation_contagion_groups

    yield

    add_foreign_key :simulation_contagion_populations,
                    :simulation_contagion_groups, column: :group_id
  end
end
