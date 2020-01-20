require 'open-uri'
require 'nokogiri'
require 'pry'

class RecipeScrapper
  def initialize(ingredient)
    @ingredient = ingredient
  end

  def top_five
    recipe_results = []
    url = "https://www.allrecipes.com/search/results/?wt=#{@ingredient}&sort=re"
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc.search('.fixed-recipe-card h3 a').each do |element|
      recipe_results << { name: element.text.strip, href: element.attribute('href').value }
    end
    @recipe_results = recipe_results.first(5)
  end

  def scrap_recipe(index)
    url = @recipe_results[index][:href]
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    steps = get_steps(html_doc)
    prep_time = get_prep_time(html_doc)
    [@recipe_results[index][:name], steps.join(" "), prep_time, "Unknown"]
  end

  private

  def get_steps(html_doc)
    steps = []
    html_doc.search('.recipe-directions__list--item').each do |element|
      steps << element.text.strip.scan(/.*\n?/)
    end
    steps.delete_at(-1)
    steps
  end

  def get_prep_time(html_doc)
    prep_time_items = []
    html_doc.search('.prepTime__item').each do |element|
      prep_time_items << element.text.strip
    end
    prep_hours = prep_time_items[-1].match(/(\d+) h/) ? prep_time_items[-1].match(/(\d+) h/)[1].to_i : 0
    prep_minutes = prep_time_items[-1].match(/(\d+) m/) ? prep_time_items[-1].match(/(\d+) m/)[1].to_i : 0
    prep_hours * 60 + prep_minutes
  end
end
