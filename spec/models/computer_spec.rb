require 'rails_helper'

RSpec.describe Computer, type: :model do
  context "validação de instancia computer" do

    it 'pc valido' do
      p = build(:computer)
      expect(p).to be_valid
    end

    it 'pc sem o preço ' do
      p = build(:computer, total_price: nil)
      expect(p).not_to be_valid
      expect(p.errors[:total_price]).to include("can't be blank")
    end

  end

end
 