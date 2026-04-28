class AddDataToComputers < ActiveRecord::Migration[8.1]
  def change
    add_column :computers, :data, :jsonb, default: {}
  end
end
