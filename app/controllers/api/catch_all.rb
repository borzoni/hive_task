# frozen_string_literal: true

module API
  module CatchAll
    extend ActiveSupport::Concern

    included do
      rescue_from ::UnauthenticatedError do
        render_json_api_error(
          status: 401,
          title: 'Not authenticated',
          description: 'Not authenticated'
        )
      end

      rescue_from ActiveRecord::RecordNotFound do |error|
        render_json_api_error(
          status: 404,
          title: 'Record Not Found',
          description: "Could not find #{error.model.underscore.humanize.downcase}"
        )
      end

      rescue_from Grape::Exceptions::ValidationErrors do |error|
        render_json_api_error(
          status: 422,
          title: 'Invalid payload',
          description: error.message
        )
      end

      rescue_from :all do
        render_json_api_error(
          status: 500,
          title: 'Internal server error',
          description: 'Something went wrong, please try again later'
        )
      end
    end
  end
end
