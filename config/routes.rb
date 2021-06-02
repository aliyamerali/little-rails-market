Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :merchants, only: [:show] do
    resources :items, only: [:index, :show]
  end
end
