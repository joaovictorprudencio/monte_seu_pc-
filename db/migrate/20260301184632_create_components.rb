class CreateComponents < ActiveRecord::Migration[8.1]
  def change
    create_table :components do |t|
      t.string :name
      t.string :brand
      t.string :category
      t.string :architecture
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
