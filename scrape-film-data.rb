require 'nokogiri'
require 'httparty'
require 'json'
require './environment'

API_URL = ENV['api_url']
API_KEY = ENV['api_key']
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
ENV['api_url'] = 'http://www.omdbapi.com/?y=2017&apikey=b927896c&t='
		resp = HTTParty.get(API_URL + title.gsub(' ', '+').gsub('\'', '')).parsed_response
    # Try current year and then the previous year
    current_year = Date.today.year.to_s
		resp = HTTParty.get(API_URL + current_year + '&apikey=' + API_KEY + '&t=' + title.gsub(' ', '+').gsub('\'', '')).parsed_response
    if resp["imdbRating"].nil?
      current_year = (Date.today.year - 1).to_s
  		resp = HTTParty.get(API_URL + current_year + '&apikey=' + API_KEY + '&t=' + title.gsub(' ', '+').gsub('\'', '')).parsed_response
    end
		rating = Film.new(title, resp["imdbRating"])
		movies.push(rating)
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
