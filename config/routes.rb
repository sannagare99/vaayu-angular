Rails.application.routes.draw do

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :devices do
    post :validate, on: :collection
  end
  resources :shifts do
    member do
      get :change_status
    end
    post :validate, on: :collection
  end
  mount ActionCable.server => '/cable'

  get 'errors/not_found'

  get 'errors/internal_server_error'

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  # Sidekiq background jobs ui
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'provisioning', to:'provisioning#index', as: :provisioning

  devise_for :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # You can have the root of your site routed with "root"
  # root 'dashboard#index'


  root :to => 'trips#index', :constraints => lambda { |request| request.env['warden'].user&.role == 'line_manager' }
  root :to => 'dashboard#index'

  resources :dashboard do
    collection do
      get :ota
      get :costs
      get :exceptions
      get :completed_trips
      get :fleet_utilization
    end
  end

  # ------------------------- Companies ------------------------------

  resources :logistics_companies do
    collection do
      get :get_all
    end
  end
  put '/logistics_companies/operator/:id', to: 'logistics_companies#operator_edit'
  delete '/logistics_companies/operator/:id', to: 'logistics_companies#operator_delete'    
  
  resources :employee_companies do
    collection do
      get :get_all
    end
  end

  resources :business_associates do
    member do
      put :update_ba
    end
    collection do
      post :details
    end
  end

  # --------------------------- Users --------------------------------
  resources :user
  get 'users', to: 'user#index'

  get '/profile', to: 'home#profile_edit', as: :user_profile_edit
  patch '/profile', to: 'home#profile_update', as: :user_profile_update
  get '/initiate_call', to: 'home#initiate_call'
  post '/update_last_active_time', to: 'home#update_last_active_time'
  post '/exotel_callback', to: 'home#exotel_callback'
  get '/badge_count', to: 'home#badge_count'
  post '/auto_cluster', to: 'home#auto_cluster'
  post '/decluster', to: 'employee_clusters#decluster'
  post '/auto_clustering_via_service', to: 'employee_trips#auto_clustering_via_service'
  get '/offline_sms', to: 'home#offline_sms_get'
  post '/offline_sms', to: 'home#offline_sms_post'
  get '/sorted_routes', to: 'home#sorted_routes'

  get '/release_info', to: 'home#release_info'

  resources :operators
  resources :employers
  resources :line_managers do
    member do
      get :invite
      get :edit_list
      post :update_employee_list
    end
  end
  resources :transport_desk_managers
  resources :drivers do
    member do
      get :invite
      post :stop_on_leave
      get :checklist
      post :update_checklist
    end
    post :validate, on: :collection
  end
  resources :employees do
    member do
      get :schedule, to: 'employee_schedules#edit'
      get :trips, to: 'employee_trips#trips'
      get :schedule_trip, to: 'employee_trips#schedule_trip'
      post :schedule, to: 'employee_schedules#update'
      post :schedule_trip_update, to: 'employee_trips#schedule_trip_update'
      get :invite, to: "employees#invite"
    end

    collection do
      get :guards
      post :validate
      post :ingest, to: 'ingest_job#create'
      get :get_geocode
      get :get_nodal_geocode
    end
  end

  resources :notifications do
    member do
      post :archive
      post :move_driver_to_next_step
      post :resolve
      post :mark_notifications_as_old
    end
  end
  resources :invoices do
    member do
      post :update_status
      post :ba_update_status
    end
    collection do
      post :generate_invoice_for_trips
      get :invoice_details
      get :ba_invoice_details
      get :trip_data
      get :bill_data
      get :completed_trips
      get :completed_vehicles
      get :customer_invoices
      get :ba_invoices
      get :ba_trip_data
      get :ba_bill_data
      get :download
      get :ba_download
      post :delete_customer_invoices
      post :delete_ba_invoices
    end
  end

  resources :zones
  resources :vehicles do
    collection do
      post :vehicle_break_down_approve_decline
    end
    member do
      post :vehicle_broke_down
      post :vehicle_ok
      get :checklist
      post :update_checklist
    end
  end
  
  get "/billing/detail_invoice/:id", to: "invoices#detail_invoice"

  resources :sites do
    member do
      put :update_site      
    end
    collection do
      post :details
    end
  end

  resource :reports do
    member do
      get :active
      get :completed
      get :utilization
      get :exceptions_summary
      get :operations_summary
      get :ota_summary
      get :otd_summary
      get :no_show_and_cancellations
      get :panic_alarms
      get :trip_logs
      get :employee_logs
      get :vehicle_deployment
      get :ota
      get :otd
      get :employee_no_show
      get :employee_satisfaction
      get :employee_activity
      get :driver_activity
      get :drivers_trip_summary
      get :employee_wise_no_show
      get :shift_fleet_utilisation_summary
      get :shift_wise_no_show
      get :trip_wise_driver_exception
      get :vendor_trip_distribution
      get :download
      post :send_report
    end
  end
  resources :analytics, :only =>[:index],  defaults: {format: :json}

  resources :trip_locations, :only =>[:index],  defaults: {format: :json}

  resources :driver_first_pickups, :only =>[:index],  defaults: {format: :json}

  # --------------------------- Trips --------------------------------

  resources :trips do
    collection do
      post :drivers_timeline
      get :guards_list      
      # post :ingest_manifest, to: 'ingest_manifest_job#create'
      # get 'ingest_manifest_jobs/:id', to: 'ingest_manifest_job#show'
      resources :ingest_job
      post :auto_assign_driver
      post :auto_assign_guard
    end
    member do
      get :employee_trips
      post :get_drivers
      post :update_employee_trips
      post :assign_driver
      post :assign_driver_submit
      post :assign_driver_exception
      post :unassign_driver_submit
      get :complete_with_exception
      post :complete_with_exception_submit
      post :book_ola_uber
      post :book_ola_uber_submit
      post :add_guard_to_trip
      get :trip_details
      get :search_driver
      post :annotate_trip
    end
  end

  resources :employee_trips do
    member do
      get :share    
      post :remove_passenger  
    end
    collection do
      get :get_clusters
      post :auto_cluster_trips
      get :add_passengers
      post :add_passengers_submit
      delete :cancel_trip_request
      post :create_trip_rosters
      get :first_shift
      post :unique_shifts
      post :set_exception_status
    end
  end

  resources :bus_trips do
    member do
      post :toggle_state
    end
  end

  resources :bus_trip_routes
  
  get :employee_trips_changes, to: 'employee_trips#employee_trip_change_requests'
  post :employee_trips_changes, to: 'employee_trips#trip_change_request_response'

  get :driver_requests, to: 'drivers#get_driver_requests'
  post :driver_requests, to: 'drivers#update_driver_requests'

  # ------------------------- api v1 ----------------------------------
  namespace :api, defaults: {format: 'json'} do
    scope :v1, module: 'v1' do
      mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks],
                                  controllers: {
                                      sessions: 'overrides/sessions',
                                      passwords: 'overrides/passwords'
                                  }

      resources :drivers, only: :show do
        member do
          get 'upcoming_trip'
          get 'last_trip_request'
          post 'on_duty'
          get 'off_duty'
          post 'change_vehicle'
          get 'report_to_duty'
          get 'vehicle_ok_now'
          get 'trip_history'
          post 'update_current_location'
          post 'heart_beat'
          post 'driver_request'
          post 'vehicle_info'
          post 'call_operator'
        end
      end

      resources :employee_trips, except: :destroy do
        member do
          post 'cancel'
          post 'rate'
          post 'exception'
          get 'dismiss_trip'
          post 'trip_rated'
          post 'employee_on_board'
        end
      end

      resources :employees, only: [ :show, :update ] do
        member do
          get 'upcoming_trip'
          get 'last_completed_trip'
          get 'upcoming_trips'
          get 'trip_history'
          post 'call_operator'
          post 'update_user_status'
        end
      end

      resources :trips, only: :show do
        member do
          get 'accept_trip_request'
          get 'decline_trip_request'
          get 'start'
          post 'verify_driver_image'
          post 'change_status_request_assigned'
          scope :trip_routes do
            post 'on_board'
            post 'driver_arrived'
            post 'completed'
            post 'resolve_exception'
            post 'not_on_board'
          end
        end
      end

      resources :trip_routes do
        member do
          post 'initiate_call'
          get 'employee_no_show'
        end
      end

      resources :trip_route_exceptions do
        member do
          get 'resolve'
        end
      end
      get :verify_email, to: "users#verify_email"
      post :set_password, to: "users#set_password"
    end
  end

  resources :employer_shift_managers
  resources :operator_shift_managers

  get "/shift_times/:id/schedule_time", to: "shift_times#schedule_time"
  get "/shift_times/:id/timings", to: "shift_times#timings"
  post "/shift_times/:id/update_time", to: 'shift_times#update_time'

  # ------------------------- api v2 ----------------------------------
  namespace :api, defaults: {format: 'json'} do
    scope :v2, module: 'v2' do
      resources :business_associates
      resources :drivers do
      collection do
        get :search
        get :validate_licence_number
        get :validate_contact_number
      end
    end
      resources :vehicles do
        collection do
          get :search
          get :find_category_seat_by_vehicle
          get :validate_plate_number
          get :get_vehicle_model_data
        end
      end
      resources :drivers, only: :show do
        member do
          post 'update_current_location'
          get 'last_trip_request'
          post 'vehicle_info'
        end
      end
    end
  end

  resource :configurators, only: [:show, :edit, :update]
  get "/configurations", to: "configurators#index"
  put '/update_config', to: 'configurators#update_config'
  put '/update_system_config', to: 'configurators#update_system_config'
  resources :compliances
end
