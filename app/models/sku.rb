# frozen_string_literal: true

class Sku < ApplicationRecord
  has_many :restocking_shipment_item
end
