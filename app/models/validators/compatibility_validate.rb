class CompatibilityValidator < ActiveModel::EachValidator 

 def validate_each(record, attribute, value)
    motherboard = record.components.find_by(category: "MOTHERBOARD")
    cpu = record.components.find_by(category: "CPU")
    ram = record.components.find_by(category: "RAM")
    case_component = record.components.find_by(category: "CASE") 


    if value.category.nil?
        errors.add(:base,"componente não encontrado")
    end
  

  case value.category
    when "CPU"
    
      if motherboard.socket != value.socket || motherboard.architecture != value.architecture
        errors.add(:base,"Incompatibilidade: A CPU não é compatível com a placa-mãe.") 
      end

    when "MOTHERBOARD"

      if value.socket != cpu.socket || value.architecture != cpu.architecture 
          errors.add(:base,"Incompatibilidade: A placa-mãe não é compatível com Processador.") 
      end

      if value.ram_type != ram.ram_type 
         errors.add( :base, "Incompatibilidade: A placa-mãe não é compatível com Processador.") 
      end

      if value.slots < ram.slots
        errors.add(:base,"Incompatibilidade: A placa-mãe não tem slots suficientes para a RAM.")
      end

    when "RAM"

    if  motherboard.ram_type != value.ram_type
        errors.add(:base,"Incompatibilidade: O tipo de RAM não é compatível com a placa-mãe.") 
    end

    if motherboard.slots < value.slots
      errors.add(:base, "A placa-mãe não tem mais slots suficientes para a RAM.") 
    end

  when "CASE"
      if value.form_factor != motherboard.form_factor 
         errors.add(:base, "Incompatibilidade: O gabinete não é compatível com a placa-mãe.") 
      end
  end
 end
end