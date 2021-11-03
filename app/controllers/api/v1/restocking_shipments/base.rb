# frozen_string_literal: true

module API
  module V1
    module RestockingShipments
      class Base < Grape::API

        helpers do
          def render_restock(rs)
            preload(rs, [:restocking_shipment_items, {restocking_shipment_items: :sku}])
            RestockingShipmentBlueprint.render_as_json(rs, view: :extended, root: :data)
          end
        end

        before do
          authenticate_user!
          @merchant = current_user.merchant
          not_found('Merchant for current user not found') unless @merchant
        end

        resource :restocking_shipments do
          desc '[Restocking routes] Get restocking shipment items by for current_user',
            success: { 
              code: 200, message: 'Restoking shipment item retrieved' 
              },
            failure: [
               { code: 401, message: 'User is not authenticated' },
               { code: 422, message: 'Invalid params' }
             ]
            
          params do
            requires :id, type: Integer
          end

          get ':id' do
            result = RestockingShipment.find_by(id: permitted_params[:id], merchant: @merchant)

            if result
              render_restock(result)
            else
              not_found("Can\'t find restocking_shipment with id=#{permitted_params[:id]}")
            end
          end
          # END GET

          desc '[Restocking routes] Create new restocking shipments request',
            success: { 
              code: 201, message: 'Restoking shipment items created' 
            },
            failure: [
             { code: 401, message: 'User is not authenticated' },
             { code: 422, message: 'Invalid params' }
           ]

          params do
            optional :estimated_arrival_date, type: Date
            optional :tracking_code, type: String
            requires :shipper, type: Hash do
              requires :shipment_provider_id, type: Integer
            end
            requires :shipping_cost, type: Integer
            requires :skus, type: Array do
              requires :id, type: Integer
              requires :quantity, type: Integer 
            end
          end

          post do
            result = RestockingShipmentInteractor.call!(permitted_params.merge(merchant: @merchant))

            if result.success?
              render_restock(result.value!)
            else
              render_failure(result.failure)
            end
          end
          # END POST
        end
      end
    end
  end
end
