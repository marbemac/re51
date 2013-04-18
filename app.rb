require 'compass'
require 'sinatra'
require 'sinatra/cache'
require 'slim'
require "sinatra/reloader" if development?

set :root, File.dirname(__FILE__)
set :cache_output_dir, Proc.new { File.join(root, 'public', 'cache') }
set :cache_enabled, true

configure do
  set :scss, {:style => :expanded, :debug_info => true}
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}" )
end

get '/' do
  @page = 'home'
  slim :home
end

get '/about' do
  @page = 'about'
  slim :about
end

get '/disciplines' do
  @page = 'disciplines'
  slim :disciplines
end

get '/portfolio' do
  @page = 'portfolio'
  slim :portfolio
end

get '/contact' do
  @page = 'contact'
  slim :contact
end