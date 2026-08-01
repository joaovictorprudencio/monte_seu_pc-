# db/seeds.rb

Component.destroy_all
Computer.destroy_all

puts "🔧 Criando Components..."

def create_component(attributes)
  component = Component.create!(attributes)
  filename = "#{component.category}_placeholder.png"
  image_path = Rails.root.join("app/assets/images/#{filename}")
  if File.exist?(image_path)
    component.image.attach(
      io: File.open(image_path),
      filename: filename,
      content_type: "image/png"
    )
  else
    default_path = Rails.root.join("app/assets/images/placeholder.png")
    component.image.attach(
      io: File.open(default_path),
      filename: "placeholder.png",
      content_type: "image/png"
    )
  end
  component
end


cpus = [
  # Intel
  { name: "Intel Core i3-13100", brand: "Intel", category: "CPU", price: 450.00, socket: "LGA1700", architecture: "Raptor Lake", wattage: 65 },
  { name: "Intel Core i5-13600K", brand: "Intel", category: "CPU", price: 1200.00, socket: "LGA1700", architecture: "Raptor Lake", wattage: 125 },
  { name: "Intel Core i7-13700K", brand: "Intel", category: "CPU", price: 1800.00, socket: "LGA1700", architecture: "Raptor Lake", wattage: 125 },
  { name: "Intel Core i9-13900K", brand: "Intel", category: "CPU", price: 2500.00, socket: "LGA1700", architecture: "Raptor Lake", wattage: 125 },

  # AMD
  { name: "AMD Ryzen 5 5600X", brand: "AMD", category: "CPU", price: 900.00, socket: "AM4", architecture: "Zen 3", wattage: 105 },
  { name: "AMD Ryzen 7 7700X", brand: "AMD", category: "CPU", price: 1400.00, socket: "AM5", architecture: "Zen 4", wattage: 105 },
  { name: "AMD Ryzen 9 7950X", brand: "AMD", category: "CPU", price: 2200.00, socket: "AM5", architecture: "Zen 4", wattage: 170 },
]

cpus.each { |cpu| create_component(cpu) }
puts "✅ #{cpus.length} CPUs criadas"


motherboards = [
  { name: "ASUS ROG STRIX B760-F", brand: "ASUS", category: "Motherboard", price: 800.00, socket: "LGA1700", form_factor: "ATX" },
  { name: "MSI MPG Z790 EDGE", brand: "MSI", category: "Motherboard", price: 1100.00, socket: "LGA1700", form_factor: "ATX" },
  { name: "ASUS ROG STRIX X870-E", brand: "ASUS", category: "Motherboard", price: 900.00, socket: "AM5", form_factor: "ATX" },
  { name: "MSI MPG B850-E EDGE", brand: "MSI", category: "Motherboard", price: 700.00, socket: "AM5", form_factor: "ATX" },
]

motherboards.each { |mb| create_component(mb) }
puts "✅ #{motherboards.length} Placas-mãe criadas"


rams = [
  # DDR4
  { name: "Corsair Vengeance LPX 8GB DDR4", brand: "Corsair", category: "RAM", price: 150.00, ram_type: "DDR4", ram_speed: 3200, slots: 1 },
  { name: "Kingston Fury Beast 16GB DDR4", brand: "Kingston", category: "RAM", price: 350.00, ram_type: "DDR4", ram_speed: 3200, slots: 2 },
  { name: "G.SKILL Trident Z 32GB DDR4", brand: "G.SKILL", category: "RAM", price: 550.00, ram_type: "DDR4", ram_speed: 3600, slots: 2 },

  # DDR5
  { name: "Corsair Dominator Platinum 16GB DDR5", brand: "Corsair", category: "RAM", price: 450.00, ram_type: "DDR5", ram_speed: 5600, slots: 1 },
  { name: "Kingston Fury Beast 32GB DDR5", brand: "Kingston", category: "RAM", price: 750.00, ram_type: "DDR5", ram_speed: 6000, slots: 2 },
  { name: "G.SKILL Trident Z5 RGB 32GB DDR5", brand: "G.SKILL", category: "RAM", price: 800.00, ram_type: "DDR5", ram_speed: 6400, slots: 2 },
]

rams.each { |ram| create_component(ram) }
puts "✅ #{rams.length} RAMs criadas"


gpus = [
  # NVIDIA
  { name: "NVIDIA GeForce RTX 3060", brand: "NVIDIA", category: "GPU", price: 1800.00, architecture: "Ampere", wattage: 170, max_gpu_length: 242 },
  { name: "NVIDIA GeForce RTX 3080", brand: "NVIDIA", category: "GPU", price: 3500.00, architecture: "Ampere", wattage: 320, max_gpu_length: 285 },
  { name: "NVIDIA GeForce RTX 4070", brand: "NVIDIA", category: "GPU", price: 2800.00, architecture: "Ada", wattage: 200, max_gpu_length: 242 },
  { name: "NVIDIA GeForce RTX 4090", brand: "NVIDIA", category: "GPU", price: 8000.00, architecture: "Ada", wattage: 450, max_gpu_length: 304 },

  # AMD
  { name: "AMD Radeon RX 6600", brand: "AMD", category: "GPU", price: 1200.00, architecture: "RDNA 2", wattage: 150, max_gpu_length: 210 },
  { name: "AMD Radeon RX 7700 XT", brand: "AMD", category: "GPU", price: 2400.00, architecture: "RDNA 3", wattage: 250, max_gpu_length: 242 },
]

gpus.each { |gpu| create_component(gpu) }


storages = [
  { name: "Kingston A2000 500GB NVMe", brand: "Kingston", category: "Storage", price: 250.00, form_factor: "M.2 NVMe" },
  { name: "Samsung 970 EVO Plus 1TB NVMe", brand: "Samsung", category: "Storage", price: 450.00, form_factor: "M.2 NVMe" },
  { name: "WD Black SN850X 2TB NVMe", brand: "Western Digital", category: "Storage", price: 900.00, form_factor: "M.2 NVMe" },
  { name: "Seagate Barracuda 1TB HDD", brand: "Seagate", category: "Storage", price: 250.00, form_factor: "3.5\" HDD" },
  { name: "WD Blue 2TB HDD", brand: "Western Digital", category: "Storage", price: 350.00, form_factor: "3.5\" HDD" },
]

storages.each { |storage| create_component(storage) }

power_supplies = [
  { name: "Corsair CV 550W", brand: "Corsair", category: "Power Supply", price: 300.00, wattage: 550 },
  { name: "EVGA SuperNOVA 750W Gold", brand: "EVGA", category: "Power Supply", price: 500.00, wattage: 750 },
  { name: "Seasonic Focus Plus 850W Gold", brand: "Seasonic", category: "Power Supply", price: 600.00, wattage: 850 },
  { name: "Corsair HX1000 Platinum", brand: "Corsair", category: "Power Supply", price: 1200.00, wattage: 1000 },
]

power_supplies.each { |psu| create_component(psu) }


cases = [
  { name: "Corsair 275R Airflow", brand: "Corsair", category: "Case", price: 400.00, form_factor: "ATX", max_gpu_length: 370 },
  { name: "NZXT H510 Flow", brand: "NZXT", category: "Case", price: 450.00, form_factor: "ATX", max_gpu_length: 325 },
  { name: "Lian Li LANCOOL 205", brand: "Lian Li", category: "Case", price: 250.00, form_factor: "mATX", max_gpu_length: 320 },
  { name: "Phanteks Eclipse P500A", brand: "Phanteks", category: "Case", price: 550.00, form_factor: "ATX", max_gpu_length: 370 },
  { name: "Fractal Design North", brand: "Fractal Design", category: "Case", price: 700.00, form_factor: "ATX", max_gpu_length: 340 },
]

cases.each { |case_item| create_component(case_item) }

computers = [
  { name: "PC Gamer Budget", description: "Build entrada para gaming", type_of_use: "Gaming", total_price: 0 },
  { name: "PC Gamer Mid-Range", description: "Build intermediaria com RTX 3070", type_of_use: "Gaming", total_price: 0 },
  { name: "PC Workstation", description: "Para design e rendering", type_of_use: "Trabalho", total_price: 0 },
]

computers.each { |computer| Computer.create!(computer) }

