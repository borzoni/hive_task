class ChangePriceToInt < ActiveRecord::Migration[6.0]
  def change
    change_column :restocking_shipments, :shipping_cost, :integer
  end
end
