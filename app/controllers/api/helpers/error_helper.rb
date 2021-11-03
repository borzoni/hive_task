# frozen_string_literal: true

module API
  module Helpers
    # Includes some basic methods used for proper representation of app-level exceptions
    # in a form of HTTP errors with JSON API compliant format
    module ErrorHelper
      extend ::Grape::API::Helpers

      def not_found(desc = '')
        render_json_api_error(
           status: 404,
          title: 'Record Not Found',
          description: desc
        )
      end

      def render_failure(err)
        if !err.is_a?(Hash)
          return render_json_api_error(
            status: 500, 
            title: 'Internal server error',
            description: 'Something went wrong, please try again later'
          )
        end

        case err[:type]
          when :validation
            render_json_api_error(
              status: 422,
              title: 'Invalid payload',
              description: err[:errors]
            )
          when :exception
            render_json_api_error(
              status: 422,
              title: 'Invalid payload',
              description: 'Exception occured while processing pipeline'
            )
          else 
            render_json_api_error(
              status: 422,
              title: 'Invalid payload',
              description: err[:errors]
            )
          end
      end

      def render_json_api_error(status:, title:, description:)
        error!(
          {
            errors: [{
              status: status,
              title: title,
              description: description
            }]
          },
          status
        )
      end
    end
  end
end
