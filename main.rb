require_relative 'lib/csn_scraper.rb'
require 'csv'

class Main
  extend CsnScraper
  titles = CSV.read('titles.csv')
  titles.each do |title|
  	title = title.first
  	results = download_song(title)
  end
  query = 'Run To You'
  results = download_song(query)
  puts results
end