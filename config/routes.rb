Rails.application.routes.draw do
  apipie
  
  namespace :api do
    namespace :v1 do
      resources :posts do
        resources :comments
      end
      post 'auth/login', to: 'authentication#login'
      post 'signup', to: 'users#create'
    end
  end
end
