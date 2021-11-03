class RestockingShipmentInteractor < Interactor

  contract do 
    params do
      required(:merchant).filled(Dry.Types.Instance(Merchant))
      optional(:estimated_arrival_date).maybe(:date)
      optional(:tracking_code).filled(:string)
      required(:shipper).hash do
        required(:shipment_provider_id).value(:integer, gt?: 0)
      end
      required(:shipping_cost).value(:integer, gt?: 0)
      required(:skus).value(:array, min_size?: 1).each do
        hash do
          required(:id).value(:integer, gt?: 0)
          required(:quantity).value(:integer, gt?: 0)
        end
      end
    end

    rule(:estimated_arrival_date) do
      key.failure('must be in the future') if value && value <= Date.today 
    end
  end

  def call!(inputs)
    restocking_shipment = RestockingShipment.create(prepared_attributes)

    if restocking_shipment.valid?
      Success(restocking_shipment)
    else
      Failure(type: :validation, errors: restocking_shipment.errors.messages)
    end
  end

  def prepared_attributes
    @parent_attributes ||= {
      shipping_cost:                        inputs[:shipping_cost],
      shipment_provider_id:                 inputs[:shipper][:shipment_provider_id],
      merchant_id:                          inputs[:merchant].id,
      estimated_arrival_date:               inputs[:estimated_arrival_date],
      tracking_code:                        inputs[:tracking_code],
      restocking_shipment_items_attributes: items_attributes
    }
  end

  def items_attributes
    @items_attributes ||= inputs[:skus]
                          .map{ |el| { sku_id: el[:id], quantity: el[:quantity] }}
  end

end
