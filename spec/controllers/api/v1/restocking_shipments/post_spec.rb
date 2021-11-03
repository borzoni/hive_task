# frozen_string_literal: true

require 'rails_helper'

describe API::V1::RestockingShipments::Base, type: :request do
  subject(:call) { post endpoint, params: params, headers: auth_header(token) }

  let(:endpoint) { '/api/v1/restocking_shipments' }
  let(:skus) { create_list(:sku, 2) }
  let(:shipment_provider) { create(:shipment_provider) }

  let(:shipping_date) { '2022-07-01' }
  let(:tracking_code) { 'YY' }
  let(:quantities) { [1, 10] }
  let(:cost) { 200 }

  let(:params) do
    {
      'estimated_arrival_date': shipping_date, 
      'tracking_code': tracking_code, 
      'shipper': { 'shipment_provider_id': shipment_provider.id }, 
      'skus': skus.each_with_index.map { |e, i| {'id': e.id, 'quantity': quantities[i] } },
      'shipping_cost': cost
    }
  end

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
    let(:merchant) { create(:merchant) }
    
    let!(:merchant_account) { create(:merchant_account, user: user, merchant: merchant) }
    let!(:user) { create(:user, email: current_user_email, password: current_user_password) }

    context 'when params valid' do
      let(:new_restock) { RestockingShipment.last }
      let(:new_restock_items) do
        new_restock.restocking_shipment_items
          .each_with_index
          .map do |e, i|
            {
              id: e.id,
              quantity: quantities[i],
              sku: { id: skus[i].id,  name: skus[i].name }
            }
        end
      end

      let(:expected_response) do
        { data: 
          {
            id: new_restock.id,
            restocking_shipment_items: new_restock_items,
            shipment_provider: {id: shipment_provider.id, name: shipment_provider.name},
            shipping_cost: cost,
            sku_count: skus.size,
            status: 'pending',
            estimated_arrival_date: shipping_date,
            tracking_code: tracking_code,
            total_count: quantities.sum 
          }
        }
      end

      it 'responds with 201 status' do
        call
        expect(response).to have_http_status(201)
      end

      it 'creates a new restock' do
        expect { call }.to \
          change(RestockingShipment, :count).by(1)
          .and \
          change(RestockingShipmentItem, :count).by(2)
      end

      it 'returns new restock data serialized to JSON' do
        call
        expect(JSON.parse(response.body).deep_symbolize_keys).to match(expected_response)
      end

      context 'with invalid params' do
        let(:shipping_date) { '2020-07-01' } # past date

        it 'responds with 422 status' do
          call
          expect(response).to have_http_status(422)
        end
      end

      context 'with missing params' do
        let(:params) do
          {
            'estimated_arrival_date': shipping_date,
            'shipper': { 'shipment_provider_id': shipment_provider.id }, 
            'skus': skus.each_with_index.map { |e, i| {'id': e.id, 'quantity': quantities[i]} },
          }
        end

        it 'responds with 422 status' do
          call
          expect(response).to have_http_status(422)
        end
      end

      context 'with optional params' do
        let(:params) do
          {
            'tracking_code': tracking_code, 
            'shipper': { 'shipment_provider_id': shipment_provider.id }, 
            'skus': skus.each_with_index.map { |e, i| {'id': e.id, 'quantity': quantities[i] } },
            'shipping_cost': cost
                }
              end

        it 'responds with 201 status' do
          call
          expect(response).to have_http_status(201)
        end
      end

      context 'with invalid type' do
        let(:shipping_date) { 'Wrong' }

        it 'responds with 422 status' do
          call
          expect(response).to have_http_status(422)
        end
      end

      context 'with empty skus' do
        let(:params) do
          {
            'estimated_arrival_date': shipping_date, 
            'tracking_code': tracking_code, 
            'shipper': { 'shipment_provider_id': shipment_provider.id }, 
            'skus': [],
            'shipping_cost': cost
          }
        end

        it 'responds with 422 status' do
          call
          expect(response).to have_http_status(422)
        end
      end

      context 'with zero quantity' do
        let(:quantities) { [0, 4] }

        it 'responds with 422 status' do
          call
          expect(response).to have_http_status(422)
        end
      end

      context 'with empty merchant' do
        let!(:merchant_account) { nil }

        it 'responds with 404 status' do
          call
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
