class ChangeTotalPriceToDecimalInComputers < ActiveRecord::Migration[8.1]
  def change
    change_column :computers, :total_price, :decimal, precision: 10, scale: 2, using: 'total_price::decimal(10,2)'
  end
end
