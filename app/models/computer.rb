class Computer < ApplicationRecord
  has_many :computer_parts
  has_many :components, through: :computer_parts
  belongs_to :user
  validates :total_price, presence: true
  validates :name, presence: true
  enum :status, { draft: 0, building: 1, completed: 2, cancelled: 3 }



  def change_part(componente, new_componente)
    computer_part = computer_parts.find_by(component_id: componente.id)

    new_price = price - component.price + new_componente.price

    update(total_price: new_price)

    computer_part.update(component_id: new_componente.id)
  end



  def save_hash(component)
    data = {
      name: self.name,
      description: description,
      type_of_use: type_of_use,
      total_price: total_price
    }

    case component.category
    when "CPU"
      data[:CPU] = component.name
    when "MOTHERBOARD"
      data[:MOTHERBOARD] = component.name
    when "GPU"
      data[:GPU] = component.name
    when "SOURCE"
      data[:SOURCE] = component.name
    when "STORAGE"
      data[:STORAGE] = component.name
    when "RAM"
      data[:RAM] = component.name
    end

    save
  end
end
