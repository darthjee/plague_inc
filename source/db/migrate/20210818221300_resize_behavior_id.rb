class ResizeBehaviorId < ActiveRecord::Migration[5.2]
  def up
    with_fk do
    end
  end

  def down
    with_fk do
    end
  end

  private

  def with_fk
    remove_foreign_key :simulation_contagion_groups, :simulation_contagion_behaviors
    remove_foreign_key :simulation_contagion_populations, :simulation_contagion_behaviors

    yield
  ensure

    add_foreign_key :simulation_contagion_groups, :simulation_contagion_behaviors, column: :behavior_id
    add_foreign_key :simulation_contagion_populations, :simulation_contagion_behaviors, column: :behavior_id
  end
end
