# frozen_string_literal: true

module API
  module Helpers
    # Provides simple method to fetch only declared and passed params
    module PermittedParamsHelper
      extend ::Grape::API::Helpers

      def permitted_params
        declared(params, include_missing: false)
      end
    end
  end
end
