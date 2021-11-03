FactoryBot.define do
  factory :restocking_shipment do
    association :merchant
    association :shipment_provider
    shipping_cost { Random.rand(100) }

    factory :restocking_shipment_with_items do
      transient do
        rsi_count { 3 }
      end

      after(:create) do |rs, evaluator|
        create_list(:restocking_shipment_item, evaluator.rsi_count, restocking_shipment: rs)
        rs.reload
      end
    end
  end
end
