class CompatibilityValidator < ActiveModel::Validator
 def validate_compatibility_part(component)
    motherboard = components.find_by(category: "MOTHERBOARD")
    cpu = components.find_by(category: "CPU")
    ram = components.find_by(category: "RAM")
    case_component = components.find_by(category: "CASE") 


    if component && component.cagegory.nil?
        error.add("componente não encontrado")
    end
  

  case component.category
    when "CPU"
    
      if motherboard.socket != component.socket || motherboard.architecture != component.architecture
        errors.add("Incompatibilidade: A CPU não é compatível com a placa-mãe.") 
      end

    when "MOTHERBOARD"

      if component.socket != cpu.socket || component.architecture != cpu.architecture 
          errors.add("Incompatibilidade: A placa-mãe não é compatível com Processador.") 
      end

      if component.ram_type != ram.ram_type 
         errors.add( "Incompatibilidade: A placa-mãe não é compatível com Processador.") 
      end

      if component.slots < ram.slots
        errors.add("Incompatibilidade: A placa-mãe não tem slots suficientes para a RAM.")
      end

    when "RAM"

    if  motherboard.ram_type != component.ram_type
        errors.add("Incompatibilidade: O tipo de RAM não é compatível com a placa-mãe.") 
    end

    if motherboard.slots < component.slots
      errors.add("A placa-mãe não tem mais slots suficientes para a RAM.") 
    end

  when "CASE"
      if component.form_factor != motherboard.form_factor 
         errors.add("Incompatibilidade: O gabinete não é compatível com a placa-mãe.") 
      end
  end
 end
end