# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry-byebug'
require 'better_errors'
require_relative 'cookbook'
require_relative 'recipe'
require_relative 'recipe_scrapper'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path(__dir__)
end

csv_file   = File.join(__dir__, 'recipes.csv')
cookbook   = Cookbook.new(csv_file)
recipe_scrapper = RecipeScrapper.new

get '/' do
  @recipes = cookbook.all
  erb :index
end

get '/new' do
  erb :new
end

post '/recipes' do
  @params = params
  @params[:id] = !cookbook.largest_id.nil? ? cookbook.largest_id + 1 : 1
  cookbook.add_recipe(Recipe.new(@params))
  cookbook.save_csv
  redirect '/'
end

get '/recipe/:id' do
  @id = params[:id].to_i
  recipes = cookbook.all
  @recipe = recipes.find { |recipe| recipe.id.to_i == @id }
  erb :recipe
end

get '/recipe/:id/delete' do
  @id = params[:id].to_i
  cookbook.remove_recipe(cookbook.id_index(@id))
  cookbook.save_csv
  redirect '/'
end

get '/delete/all' do
  cookbook.destroy_all
  cookbook.save_csv
  redirect '/'
end

get '/import' do
  erb :import
end

get '/import/choose' do
  @params = params
  @top_ten = recipe_scrapper.top_ten(@params[:ingredient])
  erb :import_choose
end

get '/import/:index' do
  @index = params[:index].to_i - 1
  scrapped_recipe = recipe_scrapper.scrap_recipe(@index)
  recipe = Recipe.new(name: scrapped_recipe[0],
            description: scrapped_recipe[1],
            prep_time: scrapped_recipe[2],
            difficulty: scrapped_recipe[3])
  cookbook.add_recipe(recipe)
  cookbook.save_csv
  redirect '/'
end
