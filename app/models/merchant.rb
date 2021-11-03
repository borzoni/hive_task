# frozen_string_literal: true

class Merchant < ApplicationRecord
  belongs_to :merchant_account,  optional: true
end
