# frozen_string_literal: true

class RestockingShipment < ApplicationRecord
  belongs_to :shipment_provider
  belongs_to :merchant

  has_many :restocking_shipment_items, dependent: :destroy # soft deletion may be needed

  accepts_nested_attributes_for :restocking_shipment_items

  enum status: {
    pending: 0,
    active: 1,
    archived: 2
  }, _prefix: true
end
