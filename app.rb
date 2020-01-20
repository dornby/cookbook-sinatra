# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry-byebug'
require 'better_errors'
require_relative 'cookbook'
require_relative 'recipe'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path(__dir__)
end

csv_file   = File.join(__dir__, 'recipes.csv')
cookbook   = Cookbook.new(csv_file)

get '/' do
  @recipes = cookbook.all
  erb :index
end

get '/new' do
  erb :new
end

post '/recipes' do
  @params = params
  @params[:id] = cookbook.largest_id + 1
  cookbook.add_recipe(Recipe.new(@params))
  cookbook.save_csv
  redirect '/'
end

get '/recipe/:id' do
  @id = params[:id].to_i
  erb :recipe
end

get '/delete/:id'
  cookbook.remove_recipe(cookbook.id_index(@id))
  cookbook.save_csv
  redirect '/'
end
