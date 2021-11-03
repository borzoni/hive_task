# frozen_string_literal: true

module AuthHeaderHelper
  def auth_header(token)
    { 'Authorization' => "Bearer #{token}" }
  end
end
