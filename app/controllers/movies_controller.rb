class MoviesController < ApplicationController
  def list
    # data = File.read("/Users/conorbroderick/development/side_projects/dublin-films-api/movies.json")
    data = File.read("/home/conor/Development/cinema-scraper/movies.json")
    hash = JSON.parse(data)
    render json: hash
  end
end
