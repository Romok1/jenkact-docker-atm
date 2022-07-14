Rails.application.routes.draw do
  get 'welcomes/index'
  resources :posts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  #root "main#index"

  root "welcomes#index"
  # root "articles#index"
end
