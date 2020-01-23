# frozen_string_literal: true

require 'csv'
require 'pry'
require_relative 'recipe'

# Repository of our recipes
class Cookbook
  attr_reader :csv_file_path
  def initialize(csv_file_path)
    @csv_file_path = csv_file_path

    @recipes = []

    CSV.foreach(csv_file_path) do |recipe|
      @recipes << Recipe.new(name: recipe[0], description: recipe[1], prep_time: recipe[2], difficulty: recipe[3], is_done: recipe[4], id: recipe[5])
    end
  end

  def all
    @recipes
  end

  def add_recipe(recipe)
    recipe.id = largest_id.to_i + 1
    recipe.is_done = false
    @recipes << recipe
  end

  def remove_recipe(recipe_index)
    @recipes.delete_at(recipe_index)
  end

  def destroy_all
    @recipes = []
  end

  def mark_as_done(index)
    @recipes[index].is_done = true
  end

  def save_csv
    csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }

    CSV.open(@csv_file_path, 'wb', csv_options) do |csv|
      @recipes.each do |to_store_recipe|
        csv << [to_store_recipe.name, to_store_recipe.description, to_store_recipe.prep_time, to_store_recipe.difficulty, false, to_store_recipe.id]
      end
    end
  end

  def largest_id
    ids = []
    @recipes.each do |recipe|
      ids << recipe.id
    end
    ids.max
  end

  def id_index(id)
    @recipes.index { |recipe| recipe.id.to_i == id }
  end
end
