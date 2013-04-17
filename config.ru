require File.join(File.dirname(__FILE__), 'app')

set :environment, ENV['RACK_ENV'].to_sym
disable :run

run Sinatra::Application