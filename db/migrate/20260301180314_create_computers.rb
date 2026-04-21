class CreateComputers < ActiveRecord::Migration[8.1]
  def change
    create_table :computers do |t|
      t.string :name
      t.string :string
      t.string :description
      t.string :text
      t.string :total_price

      t.timestamps
    end
  end
end
