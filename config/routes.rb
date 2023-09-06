Rails.application.routes.draw do
  
  resources :packages, only: [:index, :show] do
    member do
      get :dependent_packages
    end
  end

  root 'home#index'
end
