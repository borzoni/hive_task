class ChangeRestockAddNewFields < ActiveRecord::Migration[6.0]
  def change
    add_column :restocking_shipments, :estimated_arrival_date, :date, null: true
    add_column :restocking_shipments, :tracking_code, :string, null: true
  end
end
