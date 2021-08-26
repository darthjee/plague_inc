class RemoveCurrentPopulationId < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :simulation_contagion_instants,
                       :simulation_contagion_populations
    remove_column :simulation_contagion_instants, :current_population_id
  end

  def down
    add_column :simulation_contagion_instants, :current_population_id, :bigint
    add_foreign_key :simulation_contagion_instants,
      :simulation_contagion_populations, 
      column: :current_population_id
  end
end
