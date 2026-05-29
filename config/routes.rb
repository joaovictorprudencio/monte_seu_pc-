Rails.application.routes.draw do
  resources :components
  resources :computers
  root  'home#index'

   namespace :api do
    resources :computers
  end
end
 