Rails.application.routes.draw do
  scope :api do
    devise_for :users,
           defaults: { format: :json },
           path: '',
           path_names: {
             sign_in: 'login',
             sign_out: 'logout'
           }
    mount API::Base, at: '/'
  end
  
  mount GrapeSwaggerRails::Engine => '/swagger'
end
