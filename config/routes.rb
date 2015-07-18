Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'sessions'
  }
  post 'breaker', to: 'breaker#create'
  get 'breaker', to: 'breaker#show'
  root to: 'breaker#index'
  get 'ping', to: 'breaker#ping'
end
