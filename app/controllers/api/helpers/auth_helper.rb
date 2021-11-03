# frozen_string_literal: true

module API
  module Helpers
    module AuthHelper
      extend ::Grape::API::Helpers

      def current_user
        warden = env['warden']
        @current_user ||= warden.authenticate
      end

      def authenticate_user!
        raise UnauthenticatedError unless current_user.present?
      end
    end
  end
end
