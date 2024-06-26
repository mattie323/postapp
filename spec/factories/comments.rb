FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence }
    association :post  
    association :user  
  end
end
