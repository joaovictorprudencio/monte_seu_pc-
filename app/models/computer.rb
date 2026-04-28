class Computer < ApplicationRecord

   has_many :computer_parts
   has_many :components, through: :computer_parts


  def total_price=(value)
    if value.is_a?(String) && value.include?(",")
      clean_value = value.gsub(/[R$\s.]/, '').gsub(',', '.')
      super(clean_value)
    else
      super(value)
    end
  end


  def create_moutinng()

  end

 


  
end
