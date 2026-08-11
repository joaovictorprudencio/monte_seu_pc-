module Computers
  class CreateComputerService
    def initialize(component:, computer:)
      @component = component
      @computer = computer
    end

    def call
      create_assemble
    end

    private

    attr_reader :component, :computer

    def create_assemble
      computer.computer_parts.create!(component_id: component.id, computer_id: computer.id)
      computer.total_price = component.price
    end
  end
end
