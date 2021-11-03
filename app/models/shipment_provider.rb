# frozen_string_literal: true

class ShipmentProvider < ApplicationRecord
  has_many :restocking_shipments
end
