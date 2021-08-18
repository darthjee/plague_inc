class RemoveTimestamps < ActiveRecord::Migration[5.2]
  TABLES=%i[
    simulation_contagions
    simulation_contagion_groups
    simulation_contagion_behaviors
    simulation_contagion_instants
    simulation_contagion_populations
  ]

  def change
    TABLES.each do |table|
      remove_column table, :created_at
      remove_column table, :updated_at
    end
  end
end
