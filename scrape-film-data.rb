require 'nokogiri'
require 'httparty'
require 'json'
require './environment'

API_URL = ENV['api_url']
CINEMA_URL = ENV['cinema_url']

class Film
    attr_reader :title, :imdb_rating
	def initialize(title, imdb_rating)
		@title = title
		@imdb_rating = imdb_rating
	end
    
    def as_json(options={})
        {
          title: @title,
          imdb_rating: @imdb_rating
        }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
end

def scrapeEntertainmentIE()
	links = [CINEMA_URL]
	movie_titles = []
	page = HTTParty.get(links.first)
	parse_page = Nokogiri::HTML(page)
	pages = parse_page.css('#listingsdetails > div.paging.tvpaging > span.paginglinks.pagelinks1 > a')
	pages.each { |p|
		links.push(p.attributes["href"].value)
	}
	links.each { |l|
		page = HTTParty.get(l)
		ppage = Nokogiri::HTML(page)
		ppage.css('img[title]').each { |t|
			movie_titles.push(t.attributes["title"].value)
		}
	}
	movie_titles.delete_if { |m| m == "entertainment.ie" || m == ""}
	return movie_titles
end

def getIMDBRatings(movie_titles)
	movies = []
	movie_titles.each { |title|
		resp = HTTParty.get(API_URL + title.gsub(' ', '+').gsub('\'', '')).parsed_response
		movie = Film.new(title, resp["imdbRating"])
		movies.push(movie)
	}
	return movies
end

movies = scrapeEntertainmentIE() 
movies = getIMDBRatings(movies)
data = Hash.new
data["movies"] = movies

File.open("movies.json", "w") do |f|
    f.write(data.to_json)
end
