class IncreasePrecisionTotalPrice < ActiveRecord::Migration[8.1]
  def change
    change_column :computers, :total_price, :decimal, precision: 12, scale: 2
  end
end
