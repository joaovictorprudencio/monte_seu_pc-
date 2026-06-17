class CompatibilityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    motherboard = record.components.find_by(category: "MOTHERBOARD")
    cpu = record.components.find_by(category: "CPU")
    ram = record.components.find_by(category: "RAM")
    case_component = record.components.find_by(category: "CASE")

    value.each do |component|
      next if component.category.nil?

      case component.category
      when "CPU"

        if motherboard && motherboard.socket != component.socket || motherboard && motherboard.architecture != component.architecture
          record.errors.add(:base, "Incompatibilidade: A CPU não é compatível com a placa-mãe.")
        end

        if ram && ram.ram_speed > component.ram_speed
          record.errors.add(:base, "Velocidade incompatível com a memória  ram ")
        end

      when "MOTHERBOARD"

        if cpu && component.socket != cpu.socket || cpu && component.architecture != cpu.architecture
          record.errors.add(:base, "Incompatibilidade: A placa-mãe não é compatível com Processador.")
        end

        if ram && component.ram_type != ram.ram_type
          record.errors.add(:base, "Incompatibilidade: A placa-mãe não é compatível com a memória ram")
        end


        if case_component && component.form_factor != case_component.form_factor
          record.errors.add(:base, "Incompatibilidade: A placa-mãe não tem o tamanho correto para o gabinete")
        end

      when "RAM"

        if motherboard && motherboard.ram_type != component.ram_type
          record.errors.add(:base, "Incompatibilidade: O tipo de RAM não é compatível com a placa-mãe.")
        end


        if ram && ram.ram_speed > component.ram_speed
          record.errors.add(:base, "Velocidade incompatível com a memória  ram  ")
        end

      when "CASE"
        if motherboard && component.form_factor != motherboard.form_factor
          record.errors.add(:base, "Incompatibilidade: O gabinete não é compatível com a placa-mãe.")
        end
      end
    end
  end
end
