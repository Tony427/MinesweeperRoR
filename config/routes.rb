Rails.application.routes.draw do
  root 'boards#index'
  
  resources :boards, only: [:index, :show, :create] do
    collection do
      get :all
    end
  end
end