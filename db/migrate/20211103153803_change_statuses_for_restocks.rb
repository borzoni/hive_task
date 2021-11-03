class ChangeStatusesForRestocks < ActiveRecord::Migration[6.0]
  def change
    change_column :restocking_shipments, :status, :integer, default: 0  # assume it's safe, on real data we need to write conversion.
  end
end
