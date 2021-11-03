# frozen_string_literal: true

shared_context 'with authenticated user' do
  let(:auth_params) do
    {
      user: {
        email: current_user_email,
        password: current_user_password
      }
    }
  end

  let(:token) do
    post '/api/login', params: auth_params
    response.headers['Authorization']&.delete_prefix('Bearer ')
  end
end
