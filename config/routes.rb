Rails.application.routes.draw do
  get 'password_resets/create'
  get 'password_resets/edit'
  get 'password_resets/update'
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  root to: 'pages#home'
  resources :password_resets
  resources :user_sessions
  resources :items

  resources :users do
    member do
      get :groceries
    end
    collection do
      get :auto_complete
    end
  end

  resources :user_groups

  resources :groceries do
    member do
      get :items
      get :auto_complete
      post :add_items
      post :remove_item
    end
  end
end
