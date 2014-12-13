Rails.application.routes.draw do
  root to: 'groceries#index'
  resources :items
  resources :groceries
end
