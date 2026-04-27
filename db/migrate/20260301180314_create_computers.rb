class CreateComputers < ActiveRecord::Migration[8.1]
  def change
    create_table :computers do |t|
      t.string :name
      t.string :description
      t.string :type_of_use
      t.decimal :total_price, precision: 10, scale: 2

      t.timestamps
    end
  end

