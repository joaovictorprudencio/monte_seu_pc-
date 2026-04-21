class Computer < ApplicationRecord
  def assemble_computer
    @componentsList = []
    @tipe_component = []
  end

  def add_part(computer_id, component_id)
    @computer = findy(computer_id)
    @par_exist = @computer.component_id
  end
end
