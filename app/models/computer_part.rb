class ComputerPart < ApplicationRecord
  belongs_to :computer
  belongs_to :component

  validate :check_compatibility, on: %i[create update]

  private

  def check_compatibility
    return unless component&.category

    case component.category
    when "CPU"
      validate_cpu_compatibility
    when "MOTHERBOARD"
      validate_motherboard_compatibility
    when "RAM"
      validate_ram_compatibility
    when "CASE"
      validate_case_compatibility
    end
  end

  def existing_components
    @existing_components ||= computer.components.where.not(id: component.id).index_by(&:category)
  end

  def find_existing(category)
    existing_components[category]
  end

  def validate_cpu_compatibility
    motherboard = find_existing("MOTHERBOARD")
    ram = find_existing("RAM")

    if motherboard && (motherboard.socket != component.socket || motherboard.architecture != component.architecture)
      errors.add(:base, "Incompatibilidade: A CPU não é compatível com a placa-mãe.")
    end

    if ram && ram.ram_speed && component.ram_speed && ram.ram_speed > component.ram_speed
      errors.add(:base, "Velocidade incompatível com a memória RAM")
    end
  end

  def validate_motherboard_compatibility
    cpu = find_existing("CPU")
    ram = find_existing("RAM")
    case_component = find_existing("CASE")

    if cpu && (component.socket != cpu.socket || component.architecture != cpu.architecture)
      errors.add(:base, "Incompatibilidade: A placa-mãe não é compatível com Processador.")
    end

    if ram && component.ram_type != ram.ram_type
      errors.add(:base, "Incompatibilidade: A placa-mãe não é compatível com a memória ram")
    end

    if case_component && component.form_factor != case_component.form_factor
      errors.add(:base, "Incompatibilidade: A placa-mãe não tem o tamanho correto para o gabinete")
    end
  end

  def validate_ram_compatibility
    motherboard = find_existing("MOTHERBOARD")
    ram = find_existing("RAM")

    if motherboard && motherboard.ram_type != component.ram_type
      errors.add(:base, "Incompatibilidade: O tipo de RAM não é compatível com a placa-mãe.")
    end

    if ram && ram.ram_speed && component.ram_speed && ram.ram_speed > component.ram_speed
      errors.add(:base, "Velocidade incompatível com a memória RAM")
    end
  end

  def validate_case_compatibility
    motherboard = find_existing("MOTHERBOARD")

    if motherboard && component.form_factor != motherboard.form_factor
      errors.add(:base, "Incompatibilidade: O gabinete não é compatível com a placa-mãe.")
    end
  end
end
