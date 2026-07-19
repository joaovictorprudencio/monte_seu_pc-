Rails.application.routes.draw do
  root 'home#index'
  get "components/select", to: "components#select_category", as: "select_category"

  resources :components
  resources :computers

   namespace :api do
    resources :computers
  end
end
