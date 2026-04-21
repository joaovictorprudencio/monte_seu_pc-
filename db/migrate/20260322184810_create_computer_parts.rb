class CreateComputerParts < ActiveRecord::Migration[8.1]
  def change
    create_table :computer_parts do |t|
      t.references :computer, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true

      t.timestamps
    end
  end
end
