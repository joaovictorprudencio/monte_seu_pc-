class AddUserToComputers < ActiveRecord::Migration[8.1]
  def change
    add_reference :computers, :user, null: false, foreign_key: true
  end
end
