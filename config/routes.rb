RemotelyObservedTreatment::Application.routes.draw do

  devise_for :admins, controllers: { registrations: :registrations,
                                     sessions: :sessions }

  devise_for :patients, controllers: { registrations: :registrations,
                                       sessions: :sessions }

  resources :reward_rules
  resources :side_effects
  resources :medicines
  resources :pill_sequences do
    collection do
      get 'default'
    end
  end

  resources :admins
  resources :patients do
    resources :records do
      member do
        post :upload_video
        post :process_video
      end
    end
    resources :schedules
    resources :pill_times
    resources :wallet_transactions

    # resources :invoice do
        resource :download, only: [:show]
    # end
    get "invoice", to: 'downloads#invoice'

    get "report", to: 'downloads#report'

    get "invoices", to: 'patients#invoices'

    get "reports", to: 'patients#reports'


  end

  resources :records, only: [:index, :show] do
    resources :grades
  end

  resources :alerts


  # resources :wallet_transactions

  resources :notifications
  resources :applogs

  get '/dashboard', to: 'dashboard#index'
  get '/submission', to: 'dashboard#submission'
  get '/grading(/:sequence_id)', to: 'dashboard#grade', as: 'grading'
  get '/info', to: 'dashboard#additional_info'
  get '/help', to: 'faq#help'
  get '/feedback', to: 'faq#feedback'
  get '/wallet_balance_for_patient/:patient_id', to: 'wallet_balances#show'
  get '/wallets', to: 'patients#wallets'

  get '/calendar/:month/:year', to: 'patients#show_calendar'

  get 'patients/:id/record', to: 'patients#record'

  get '/key', to: 'dashboard#key'  #return decryption key



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root to: 'home#index'

end
