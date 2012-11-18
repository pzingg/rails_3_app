Rails3App::Application.routes.draw do

  get "logout" => "sessions#destroy", :as => "logout"
  get "login"  => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"
  get "dashboard" => "home#show", :as => "dashboard"
  root :to => "home#index"
  
  resources :logins
  resources :users
  resources :sessions
  resources :activations
  resources :password_resets
end
