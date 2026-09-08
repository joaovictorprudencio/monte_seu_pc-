Rails.application.routes.draw do
  root 'home#index'
  get "components/select", to: "components#select_category", as: "select_category"

  resources :components
  resources :computers do
    member do
      patch :create_assemble
      get :review
      patch :increment_component
      delete :decrement_component
    end
  end

   namespace :api do
    resources :computers
  end
end
