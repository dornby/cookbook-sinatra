class Recipe
  attr_accessor :name, :description, :prep_time, :difficulty, :is_done
  attr_reader :id

  def initialize(attributes = {})
    @name = attributes[:name]
    @description = attributes[:description]
    @prep_time = attributes[:prep_time]
    @difficulty = attributes[:difficulty]
    @is_done = false
    @id = attributes[:id]
  end
end
