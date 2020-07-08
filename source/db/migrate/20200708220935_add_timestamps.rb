class AddTimestamps < ActiveRecord::Migration[5.2]
  def up
    %i[
      simulations simulation_contagion_groups simulation_contagion_behaviors
    ].each do |table|
      change_table table do |t|
        t.timestamps default: Time.now
        t.change_default :created_at, nil
        t.change_default :updated_at, nil
      end
    end
  end

  def down
    %i[
      simulations simulation_contagion_groups simulation_contagion_behaviors
    ].each do |table|
      change_table table do |t|
        t.remove :created_at
        t.remove :updated_at
      end
    end
  end
end
