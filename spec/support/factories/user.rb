# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { Faker::Lorem.characters(number: 10) }
    email { Faker::Internet.email }
  end
end
