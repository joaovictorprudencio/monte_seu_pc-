class Computer < ApplicationRecord

   has_many :computer_parts
   has_many :components, through: :computer_parts


  def total_price=(value)
    if value.is_a?(String) && value.include?(",")
      clean_value = value.gsub(/[R$\s.]/, '').gsub(',', '.')
      super(clean_value)
    else
      super(value)
    end
  end


  def create_moutinng(componets) 
    componets.each do |componente |
    computer_parts.create(component_id: componente.id,computer_id: self.id)
    caclculate_total_price(componente.price)
    end 
  end


  def calculate_total_price(price)
    update(total_price: total_price + price)
  end

  

  def change_part(componente, new_componente)
    computer_part = computer_parts.find_by(component_id: componente.id)

    unless computer_part
      raise ActiveRecord::RecordNotFound, "Componente não encontrado na máquina"
    end

    new_price = self.price - component.price + new_componente.price
    update(total_price: new_price)

    computer_part.update(component_id: new_componente.id)
  end


  

  def save_hash(component)
    self.data = {
      name: self.name,
      description: self.description,
      type_of_use: self.type_of_use,
      total_price: self.total_price,
    }

    case component.category
    when "CPU"
      self.data[:CPU] = component.name
    when "MOTHERBOARD"
      cpu = component.findy_by(component_id: component.id)
      self.data[:MOTHERBOARD] = component.name  
    when "GPU"
      self.data[:GPU] = component.name
    when "SOURCE"
      self.data[:SOURCE] = component.name
    when "STORAGE"
      self.data[:STORAGE] = component.name
    when "RAM"
      self.data[:RAM] = component.name
    end  
  end


  

  
end 
