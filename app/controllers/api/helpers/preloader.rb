# frozen_string_literal: true

module API
  module Helpers
    module Preloader
      extend ::Grape::API::Helpers

      def preload(object, preloaded_associations)
        ActiveRecord::Associations::Preloader.new.preload(
          object, 
          preloaded_associations
        )
      end
    end
  end
end
