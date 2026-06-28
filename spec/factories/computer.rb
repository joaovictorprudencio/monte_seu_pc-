FactoryBot.define do
  factory :computer do
    name { "Pichal Kairos III" }
    description { "Computador para jogos em 1440p e desenvolvimento" }
    total_price { 8500.00 }
    type_of_use { "Gaming" }
    data { {
      cpu: "Ryzen 7 7800X3D",
      gpu: "RTX 4070",
      ram: "32GB DDR5",
      storage: "1TB NVMe"
    } }
  end
end
