Rails.application.routes.draw do
  resources :components
  resources :computers
  get 'home/index', to: 'home#index'
end
