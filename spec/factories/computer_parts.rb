FactoryBot.define do
  factory :computer_part do
    association :component
    association :computer
  end
end