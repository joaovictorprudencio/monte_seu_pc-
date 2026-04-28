Rails.application.routes.draw do
  resources :components
  resources :computers
  root  'home#index'
end
