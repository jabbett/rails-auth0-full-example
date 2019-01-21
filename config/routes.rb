Rails.application.routes.draw do
  get 'auth/oauth2/callback' => 'sessions#callback'
  get 'auth/failure' => 'sessions#failure'
  get 'logout' => 'sessions#logout'
  get 'change_password' => 'sessions#change_password'

  # See config/initializers/high_voltage.rb for config
  # that points / to 'view/pages/home'

  get 'secure' => 'secure#show'
  get 'user' => 'users#show'
end
