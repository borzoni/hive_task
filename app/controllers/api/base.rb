# frozen_string_literal: true

module API
  class Base < Grape::API
    include CatchAll
    helpers Helpers::PermittedParamsHelper
    helpers Helpers::AuthHelper
    helpers Helpers::ErrorHelper
    helpers Helpers::Preloader
    mount V1::Base

    add_swagger_documentation(
      mount_path: '/docs',
      array_use_braces: true,
      info: {
        title: 'Hive API',
        description: 'To obtain the api key, use the /login endpoint '\
                     '(the token will be returned in the "authorization" header)'
      },
      security_definitions: {
        jwt_token: {
          type: 'apiKey',
          name: 'Authorization',
          in: 'header'
        }
      }
    )
  end
end
