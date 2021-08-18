class ResizeBehaviorId < ActiveRecord::Migration[5.2]
  def up
    with_fk do
      change_column :simulation_contagion_behaviors, :id, :integer, null: false, unique: true, auto_increment: true
      change_column :simulation_contagion_groups, :behavior_id, :integer
      change_column :simulation_contagion_populations, :behavior_id, :integer, null: false
    end
  end

  def down
    with_fk do
      change_column :simulation_contagion_behaviors, :id, :bigint, null: false, unique: true, auto_increment: true
      change_column :simulation_contagion_groups, :behavior_id, :bigint
      change_column :simulation_contagion_populations, :behavior_id, :bigint, null: false
    end
  end

  private

  def with_fk
    remove_foreign_key :simulation_contagion_groups, :simulation_contagion_behaviors
    remove_foreign_key :simulation_contagion_populations, :simulation_contagion_behaviors

    yield

    add_foreign_key :simulation_contagion_groups, :simulation_contagion_behaviors, column: :behavior_id
    add_foreign_key :simulation_contagion_populations, :simulation_contagion_behaviors, column: :behavior_id
  end
end
