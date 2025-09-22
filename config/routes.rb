require 'sidekiq/web'
require 'sidekiq/cron/web'
Rails.application.routes.draw do
  resources :teachers, only: [:index]
  resources :teacher_schedules, only: [:index]
  
  namespace :admin do 
    resources :exams_schedules, only: [:index, :create, :update, :destroy] do
      collection do
        get :editor, defaults: { format: :turbo_stream }
      end
    end
    resources :special_periods, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :test_schedules, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      collection do
        get :editor
      end
    end

    resources :lecture_schedules, only: [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        get :editor
      end
    end
    resources :added_schedules, only: [:create, :destroy, :edit, :update]
    resources :deleted_schedules, only: [:create, :destroy]
    resources :transfer_schedules, only: [:index] do 
      collection do
        get :schedule_for_date
        post :update_sidebar
      end
    end
    resources :academic_periods, only: [:new, :create, :destroy, :edit, :update, :destroy]
    resources :default_schedules, only: [:index, :create, :update, :destroy] do
      get 'editor', on: :collection, as: :editor
    end
    resources :teachers do
      collection do
        get 'search', to: 'teachers/search#index', as: 'search'
      end
    end
    resources :classrooms do
      collection do
        get 'search', to: 'classrooms/search#index', as: 'search'
      end
    end
    resources :faculties do
      resources :student_groups
    end
    resources :student_groups do
      get 'academic_period', to: 'academic_periods#academic_period'
    end
    get '/faculties/:faculty_id/student_groups/delete', to: 'student_groups#delete', as: 'delete_student_group'
    authenticate :user, ->(user) { user.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  end
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  post "keys", to: "home#keys"

  resources :faculties, only: [:index, :show]

  get "student_schedule/index"
end
