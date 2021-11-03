FactoryBot.define do
  factory :restocking_shipment_item do
    association :restocking_shipment
    association :sku
    quantity { Random.rand(100) }
  end
end
