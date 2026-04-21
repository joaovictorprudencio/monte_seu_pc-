class CreateComponents < ActiveRecord::Migration[8.1]
  def change
    create_table :components do |t|
      t.string :name
      t.string :brand
      t.references :computer, null: false, foreign_key: true
      t.string :category
      t.string :architecture
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
