class ChangeRamSpeedToIntegerInComponents < ActiveRecord::Migration[8.1]
  def up
    change_column :components, :ram_speed, :integer, using: 'ram_speed::integer'
  end

  def down
    change_column :components, :ram_speed, :string
  end
end