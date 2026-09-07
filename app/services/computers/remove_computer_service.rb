module Computers
  class RemoveComputerService
    def initialize(computer:, computer_part:)
      @computer = computer
      @computer_part = computer_part
    end

    def call
      remove_component
    end

    private

    attr_reader :computer, :computer_part

    def remove_component
      component = computer_part.component
      computer_part.destroy!
      computer.decrement!(:total_price, component.price)
    end
  end
end
