class AddStatusToComputers < ActiveRecord::Migration[8.1]
  def change
    add_column :computers, :status, :integer
  end
end
