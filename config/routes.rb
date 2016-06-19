Rails.application.routes.draw do
  resources :clubs
  root to: 'welcome#index'
end
