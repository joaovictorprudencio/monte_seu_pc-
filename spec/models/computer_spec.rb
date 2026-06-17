require 'rails_helper'

RSpec.describe Computer, type: :model do
  context "Validações do PC" do
    let(:computer) { create(:computer) }
    let(:component_cpu) { create(:component, category: "CPU", name: "AMD Ryzen 5 5600GT", price: 799.90, ram_speed: 3200) }
    let(:component_mtb) { create(:component, category: "MOTHERBOARD", name: "B550M Aorus Elite", price: 850.00, socket: "AM4", form_factor: "ATX", slots: 2) }
    let(:component_ram) { create(:component, category: "RAM", name: "Corsair Vengeance 16GB", price: 250.00, ram_type: "DDR4", ram_speed: 3200) }
    let(:component_gpu) { create(:component, category: "GPU", name: "RTX 4060 8GB", price: 1850.00, wattage: 115) }
    let(:component_psu) { create(:component, category: "PSU", name: "Corsair CV650", price: 380.00, wattage: 650) }
    let(:component_ssd) { create(:component, category: "Storage", name: "SSD Kingston NV2 1TB", price: 420.00) }
    let(:component_case) { create(:component, category: "CASE", name: "Gabinete Mid Tower", form_factor: "ATX", price: 200.00) }

    let!(:part_cpu)  { create(:computer_part, computer: computer, component: component_cpu) }
    let!(:part_mtb) { create(:computer_part, computer: computer, component: component_mtb) }
    let!(:part_ram)  { create(:computer_part, computer: computer, component: component_ram) }
    let!(:part_gpu)  { create(:computer_part, computer: computer, component: component_gpu) }
    let!(:part_psu)  { create(:computer_part, computer: computer, component: component_psu) }
    let!(:part_ssd)  { create(:computer_part, computer: computer, component: component_ssd) }
    let!(:part_case) { create(:computer_part, computer: computer, component: component_case) }

    it 'computador  valido' do
      expect(computer).to be_valid
    end

    it 'computador  sem o preço' do
      computer.total_price = nil
      expect(computer).not_to be_valid
      expect(computer.errors[:total_price]).to include("can't be blank")
    end

    it 'nome pra montagem obrigatorio' do
      computer.name = nil
      expect(computer).not_to be_valid
      expect(computer.errors[:name]).to include("can't be blank")
    end

    it 'processador incompatível com socket da placa mae ' do
      component_mtb.update!(socket: "AMD4")
      component_cpu.update!(socket: "AMD5")
      expect(computer.reload).not_to be_valid
      expect(computer.errors[:base]).to include("Incompatibilidade: A CPU não é compatível com a placa-mãe.")
    end

     it 'processador incompatível com a velocidade de transmissão da memória ram ' do
      component_ram.update!(ram_speed: 4000)
      component_cpu.update!(ram_speed: 3500)
      expect(computer.reload).not_to be_valid
      expect(computer.errors[:base]).to include("Velocidade incompatível com a memória  ram ")
    end

    it 'placa mãe com tamanho errado para o gabinete' do
      component_mtb.update!(form_factor: "Micro-ATX")
      expect(computer.reload).not_to be_valid
      expect(computer.errors[:base]).to include("Incompatibilidade: O gabinete não é compatível com a placa-mãe.")
    end


  end
end
