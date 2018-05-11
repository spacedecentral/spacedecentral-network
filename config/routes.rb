Rails.application.routes.draw do
  resources :publication_authors
  resources :publication_long_lats
  resources :user_careers
  resources :educations
  resources :tag_references
  resources :tags
  resources :contacts, only: [:create]

  root to: "landing#index"

  mount ActionCable.server => '/cable'

  resources :notifications
  resources :user_publications do
    member do
      post :request_full_text
      get  :download_document
    end

    collection do
      post '/approve_request/:user_publication_perprogram_id', action: :approve_request, as: :approve_request
      post '/deny/:user_publication_perprogram_id', action: :deny_request, as: :deny_request
    end
  end
  resources :skills
  resources :user_skills
  resources :messages
  resources :conversations
  get '/space-chat', to: 'conversations#index'
  resources :followings, only: [], constraints: { id: /[0-z\.]+/ } do
    member do
      post :follow
      delete :unfollow
    end
  end

  devise_for :users, skip: [:sessions], controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    unlocks: 'users/unlocks',
    passwords: 'users/passwords',
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  get '/users', to: redirect('/people')
  get "/people", to: 'users#index'
  get '/settings', to: 'users#settings'

  as :user do
    get 'log-in', to: 'devise/sessions#new', as: :new_user_session
    post 'log-in', to: 'devise/sessions#create', as: :user_session
    match 'log-out', to: 'devise/sessions#destroy', as: :destroy_user_session, via: Devise.mappings[:user].sign_out_via
  end

  resources :users, only: [:edit, :update, :show, :index, :search], constraints: { id: /[0-z\.]+/ } do
    member do
      get :load_more_activities
      get :edit_user_education
      patch :update_user_education
      get :edit_settings
    end
    collection do
      get :search
      patch :update_settings
      post :generate_new_password_email
    end
  end

  get "/forum", to: 'posts#index'
  scope "/forum" do
    get "/program/:program_id", to: 'posts#index_program'
    get "/tag/:tag_id", to: 'posts#index_tag', as: :forum_tag, action: :index_tag
    resources :posts do
      member do
        put '/', as: :toggle_pin, action: :toggle_pin
      end
      collection do
        get :filter
      end
    end
  end

  get "/dashboard", to: "manage_users#index"
  get "/admin/manage/users/new_account", to: "manage_users#new_account"
  post "/admin/manage/users/create_account", to: "manage_users#create_account"
  get "/admin/manage/users/resend_confirmation", to: "manage_users#resend_confirmation_instructions"
  get "/admin/manage/users/send_password_reset", to: "manage_users#send_password_reset"

  resources :replies, except: [:index]

  resources :likes, only: [:create]

  resources :report_contents, only: [:new, :create]

  resources :programs do
    collection do
      get :search
    end
    member do
      get :tab_render_control
    end
    resources :gdrive do
      collection do
        get :listsharefiles
        get :sharegfile
        get :creategfile
      end
    end
    resources :program_user_roles do
        member do
          get :accept_membership
          get :join
          post :join
        end
    end
  end

  scope "/programs" do
    resources :gdrive do
      collection do
        get :oauthdrivecallback
      end
    end
  end

  match 'attachments/upload', to: 'attachments#upload', via: [:post, :patch]
end
