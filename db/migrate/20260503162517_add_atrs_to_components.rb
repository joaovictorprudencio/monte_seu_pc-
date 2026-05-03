class AddAtrsToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :socket, :string
    add_column :components, :ram_type, :string
    add_column :components, :form_factor, :string
    add_column :components, :wattage, :integer
    add_column :components, :slots, :integer
    add_column :components, :max_gpu_length, :integer
  end
end  
