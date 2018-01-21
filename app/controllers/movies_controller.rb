class MoviesController < ApplicationController
  def list
    data = File.read("/Users/conorbroderick/development/dublin-films-api/movies.json")
    hash = JSON.parse(data)
    render json: hash
  end
end
