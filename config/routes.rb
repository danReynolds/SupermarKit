Rails.application.routes.draw do

  post 'oauth/callback' => 'oauths#callback'
  get 'oauth/callback' => 'oauths#callback' # for use with Github, Facebook
  get 'oauth/:provider' => 'oauths#oauth', :as => :auth_at_provider

  get 'login' => 'user_sessions#new', as: :login
  post 'logout' => 'user_sessions#destroy', as: :logout
  get 'about' => 'pages#about', as: :about
  root to: 'pages#home'

  get '.well-known/acme-challenge/r5HDrACnaM2ybg60aqyLe_dEp12KUKF08dvxEqpB-EU', to: 'pages#letsencrypt1'
  get '.well-known/acme-challenge/aFTJ-03bQlZyNNyf6aEBqRbgq9V5zv30RstBfyj7RWg', to: 'pages#letsencrypt2'
  get '.well-known/acme-challenge/Xhf5BYHEqjCK80Kt7IXnM8c_u4XsZhhROQXgFOYPdlM', to: 'pages#letsencrypt3'
  get '.well-known/acme-challenge/GcKxDz-FUSVaVZPxS0usQ-D2pjx2oJLsEL4kapxOGns', to: 'pages#letsencrypt4'

  resources :user_sessions
  resources :users, except: [:index] do
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
      resources :groceries, except: [:update, :index, :edit] do
        resources :recipes, module: :groceries, only: [] do
          collection do
            patch :update
          end
        end
        resources :checkouts, module: :groceries, only: [:create] do
          collection do
            get :show
          end
        end
        resources :items, module: :groceries, only: [] do
          collection do
            get :show
            patch :update
          end
        end
        resources :receipts, module: :groceries, only: [:create] do
          collection do
            get :show
            post :confirm
          end
        end
        resources :items, only: [:update] do
          collection do
            get :auto_complete
          end
        end
        member do
          patch :receipt
          patch :do_checkout
          patch :update_store
          post :email_group
        end
      end
      member do
        get :payments
        patch :accept_invitation
        patch :do_payment
        patch :leave
      end
    end
  end
end
