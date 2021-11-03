# frozen_string_literal: true

require 'rails_helper'

describe API::V1::RestockingShipments::Base, type: :request do
  subject(:call) { get endpoint, headers: auth_header(token) }

  let(:endpoint) { "/api/v1/restocking_shipments/#{id}" }
  let(:merchant) { create(:merchant) }

  let(:restocking_shipment) { create(:restocking_shipment_with_items, merchant: merchant) }

  let(:id) { restocking_shipment.id }

  context 'when not authenticated' do
    let(:token) { nil }

    it 'responds with 401 status' do
      call
      expect(response).to have_http_status(401)
    end
  end

  context 'with authenticated user' do
    include_context 'with authenticated user'

    let(:current_user_email) { 'existing_user@example.com' }
    let(:current_user_password) { 'Password123' }
    
    let!(:merchant_account) { create(:merchant_account, user: user, merchant: merchant) }
    let!(:user) { create(:user, email: current_user_email, password: current_user_password) }

    context 'when params valid' do
      let(:restock_items) do
        restocking_shipment.restocking_shipment_items
          .each_with_index
          .map do |e, i|
            {
              id: e.id,
              quantity: e.quantity,
              sku: { id: e.sku.id,  name: e.sku.name }
            }
        end
      end

      let(:expected_response) do
        { data: 
          {
            id: restocking_shipment.id,
            restocking_shipment_items: restock_items,
            shipment_provider: { id: restocking_shipment.shipment_provider.id, name: restocking_shipment.shipment_provider.name },
            shipping_cost: restocking_shipment.shipping_cost,
            sku_count: restock_items.size,
            status: restocking_shipment.status,
            estimated_arrival_date: restocking_shipment.estimated_arrival_date,
            tracking_code: restocking_shipment.tracking_code,
            total_count: restock_items.map{ |rsi| rsi[:quantity] }.sum
          }
        }
      end

      it 'responds with 200 status' do
        call
        expect(response).to have_http_status(200)
      end

      it 'returns restock data serialized to JSON' do
        call
        expect(JSON.parse(response.body).deep_symbolize_keys).to match(expected_response)
      end

      context 'with empty merchant' do
        let!(:merchant_account) { nil }

        it 'responds with 404 status' do
          call
          expect(response).to have_http_status(404)
        end
      end

      context 'with non-existing restock ID' do
        let(:id) { restocking_shipment.id + 1 }

        it 'responds with 404 status' do
          call
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
