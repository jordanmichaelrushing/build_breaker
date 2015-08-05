Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'sessions'
  }
  post 'breaker', to: 'breaker#create'
  put 'breaker', to: 'breaker#update'
  get 'breaker', to: 'breaker#show'
  root to: 'breaker#index'
  get 'ping', to: 'breaker#ping'
  post 'saying', to: 'sayings#create'
end
