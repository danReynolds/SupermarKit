Rails.application.routes.draw do
  get 'password_resets/create'
  get 'password_resets/edit'
  get 'password_resets/update'
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  root to: 'pages#home'
  resources :password_resets
  resources :user_sessions
  resources :users
  resources :items

  resources :groceries do
    member do
      post :add_items
      get :auto_complete
    end
  end
end
