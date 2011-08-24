require 'siege_load_test_application_controller'
ActionController::Base.send :include, SiegeLoadTestApplicationController
ActionController::Base.send :before_filter, :siege_login