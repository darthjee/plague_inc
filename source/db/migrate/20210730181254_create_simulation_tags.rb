class CreateSimulationTags < ActiveRecord::Migration[5.2]
  def change
    create_join_table :simulations, :tags
  end
end
