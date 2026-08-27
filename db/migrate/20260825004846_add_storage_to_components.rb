class AddStorageToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :storage, :integer
  end
end
