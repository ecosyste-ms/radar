Rails.application.routes.draw do
  
  resources :packages, only: [:index, :show]

  root 'home#index'
end
