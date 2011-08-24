ActionController::Routing::Routes.draw do |map|
  map.namespace :testing do |test|
    test.resources :siege_load_tests, :only => [:new, :create, :index, :show]
  end
end