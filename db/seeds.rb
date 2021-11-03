# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# curl -X POST -d '{ "user": { "email": "test@test.de", "password": "1234567" } }' 'http://localhost:3000/api/login' -H Content-Type:application/json -v
# use this command to get jwt token in response in Authorization header

user = User.create(email: 'test@test.de', password: '1234567')
merchant = Merchant.create(name: 'TestMerchant')
mech_acc = MerchantAccount.create(user: user, merchant: merchant)
skus = Sku.create([{name: 'first'}, {name: 'second'}])
provider = ShipmentProvider.create(name: 'TestProvider')
