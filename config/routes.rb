Whattoplay::Application.routes.draw do
  post '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  get '/signout' => 'sessions#destroy', as: :signout
  get '/signin' => 'sessions#new', as: :signin
  post '/' => 'steam#find_games', as: :find_games
  get '/privacy' => 'steam#privacy', as: :privacy

  root to: 'steam#index'
end
