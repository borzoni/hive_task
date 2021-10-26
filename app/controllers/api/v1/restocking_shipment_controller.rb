module Api
  module V1
    class RestockingShipmentController < ApiController
      before_action :authenticate_request!

      FREE_CHOICE = "[input]"
      HARDCODED_VALUE = "Hive"


      def new
        #TODO
      end


      def show
        merchant = Merchants::FetchUserMerchant.call(@current_user.id).result
        return fail! "configure merchant" unless merchant

        restocking_shipment = RestockingShipment.find_by(id: params[:id].to_i, merchant: merchant)
        return not_found! "restocking shipment for merchant #{merchant.id} does not exist" unless restocking_shipment

        success! RestockingShipmentBlueprint.render_as_hash(restocking_shipment, view: :extended)
      end


    end
  end
end
