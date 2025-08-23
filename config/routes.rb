Rails.application.routes.draw do
  root 'web/boards#index'
  
  # Test route
  get 'test', to: 'test#index'
  
  # Web routes
  scope module: :web do
    resources :boards, only: [:index, :show, :create] do
      collection do
        get :all
      end
    end
  end
  
  # API routes
  namespace :api do
    namespace :v1 do
      resources :boards, only: [:index, :show, :create] do
        collection do
          get :recent
          get :stats
        end
      end
    end
  end
end