class AddRamSpeedToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :ram_speed, :string
  end
end
