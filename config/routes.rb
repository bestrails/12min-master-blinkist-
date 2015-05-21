Rails.application.routes.draw do
  devise_for :users, :controllers => { 
    :invitations => 'users/invitations', 
    :registrations => 'users/registrations',
    :omniauth_callbacks => 'users/omniauth_callbacks'
  }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  namespace :admin, path: '/', constraints: { subdomain: 'admin' }  do
    resources :books
    resources :discounts

    root :to => 'books#index', as: :admin_root
  end

  # You can have the root of your site routed with "root"
  authenticated :user do
    root :to => 'library#index', as: :authenticated_root
  end
  root 'home#landing'
  get 'about', to: 'home#about'
  get 'how_it_works', to: 'home#how_it_works'
  get 'press', to: 'home#press'
  get 'pricing', to: 'home#pricing'
  get 'privacy', to: 'home#privacy'
  get 'testimonials', to: 'home#testimonials'
  get 'landing', to: 'home#landing'
  get 'jobs', to: 'home#jobs'
  get 'publishers', to: 'home#publishers'
  get 'affiliates', to: 'home#affiliates'
  get 'disclaimer', to: 'home#disclaimer'

  resources :users, only: [:show, :destroy, :update] do
    member do
      get :edit
    end
    collection do
      put :set_session_close_info
    end
  end

  constraints Constraint::BookUrlConstrainer.new do
    get '/:id', to: 'books#show', as: :book
  end
  resources :books, except: :show do
    member do
      put :pick
      put :read
      put :pocket
      put :kindle
      get :content
    end
  end

  resources :library

  resources :subscriptions do
    collection do
      put :update
      put :pay
      get :promotion
    end
  end

  resources :discount do
    collection do
      put :take
    end
  end

  resources :categories, controller: :tags, only: [:index, :show]
end
