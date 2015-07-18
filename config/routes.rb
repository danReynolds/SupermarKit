Rails.application.routes.draw do

  post 'oauth/callback' => 'oauths#callback'
  get 'oauth/callback' => 'oauths#callback' # for use with Github, Facebook
  get 'oauth/:provider' => 'oauths#oauth', :as => :auth_at_provider

  get 'login' => 'user_sessions#new', as: :login
  post 'logout' => 'user_sessions#destroy', as: :logout
  get 'about' => 'pages#about', as: :about
  root to: 'pages#home'

  resources :user_sessions

  resources :users do
    member do
      get :activate
      patch :default_group
    end
    collection do
      get :auto_complete
    end
  end

  # Only the collection routes of the children get member routes of the parent
  shallow do
    resources :user_groups do
      resources :groceries do
        resources :items do
          collection do
            get :auto_complete
            patch :add
          end
          member do
            patch :remove
          end
        end
        member do
          get :recipes
          patch :finish
          post :email_group
          post :set_store
        end
      end
      member do
        get :metrics
        patch :accept_invitation
      end
    end
  end
end
