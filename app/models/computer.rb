class Computer < ApplicationRecord
  has_many :computer_parts
  has_many :components, through: :computer_parts

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

  def validate_compatibility(component)
    motherboard = components.find_by(category: "MOTHERBOARD")
    cpu = components.find_by(category: "CPU")
    ram = components.find_by(category: "RAM")
    case_component = components.find_by(category: "CASE") 

    case component.category
    when "CPU"
     
      unless motherboard
         raise ActiveRecord::RecordNotFound, "Placa-mãe não encontrada"
      end

      if motherboard.socket != component.socket || motherboard.architecture != component.architecture
        raise "Incompatibilidade: A CPU não é compatível com a placa-mãe."
      end

    when "MOTHERBOARD"
      raise ActiveRecord::RecordNotFound, "Placa-mãe não encontrada" unless motherboard

      if component.socket != cpu.socket || component.architecture != cpu.architecture
          raise "Incompatibilidade: A placa-mãe não é compatível com Processador."
      end

      if component.ram_type != ram.ram_type 
        raise "Incompatibilidade: A placa-mãe não é compatível com a RAM."
      end

      if component.slots < ram.slots
        raise "Incompatibilidade: A placa-mãe não tem slots suficientes para a RAM."
      end

    when "RAM"
    unless motherboard
      
    end


     if motherboard && motherboard.ram_type != component.ram_type
        raise "Incompatibilidade: O tipo de RAM não é compatível com a placa-mãe."
      end


    if motherboard.slots < component.slots
      raise "Incompatibilidade: A placa-mãe não tem slots suficientes para a RAM."
    end

  when "CASE"
    unless case_component
        raise ActiveRecord::RecordNotFound, "Gabinete não encontrado"
    end

      if component.form_factor != motherboard.form_factor 
        raise "Incompatibilidade: O gabinete não é compatível com a placa-mãe."
      end
  end

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
