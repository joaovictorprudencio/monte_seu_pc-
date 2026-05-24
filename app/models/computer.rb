class Computer < ApplicationRecord
  has_many :computer_parts
  has_many :components, through: :computer_parts
  validates :components, compatibility: true

  def total_price=(value)
    if value.is_a?(String) && value.include?(",")
      clean_value = value.gsub(/[R$\s.]/, "").gsub(",", ".")
      super(clean_value)
    else
      super(value)
    end
  end

  def create_mounting(components_list)
    components_list.each do |component|
      computer_parts.create(component_id: component.id, computer_id: id)
      calculate_total_price(component.price)
    end
  end

  def calculate_total_price(price)
    update(total_price + price)
  end

  

  def change_part(componente, new_componente)
    computer_part = computer_parts.find_by(component_id: componente.id)

    new_price = self.price - component.price + new_componente.price

    update(total_price: new_price)

    computer_part.update(component_id: new_componente.id)

  end



  def save_hash(component)
    data = {
      name: self.name,
      description: description,
      type_of_use: type_of_use,
      total_price: total_price,
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
