class Component < ApplicationRecord
  has_many :computer_parts
  has_many :computers, through: :computer_parts
  has_one_attached :image



end
   