FactoryBot.define do
  factory :component do
    architecture { "x86_64" }
    brand { "AMD" }
    category { "CPU" }
    form_factor { "AM4" }
    max_gpu_length { nil }
    name { "AMD Ryzen 5 5600GT" }
    price { 799.90 }
    ram_type { "DDR4" }
    ram_speed { 3200 }
    slots { nil }
    socket { "AM4" }
    updated_at { "2026-05-03T10:00:00Z" }
    wattage { "65" }
  end
end
