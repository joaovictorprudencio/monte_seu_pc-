class ComputerPart < ApplicationRecord
  belongs_to :computer
  belongs_to :component
 
end
