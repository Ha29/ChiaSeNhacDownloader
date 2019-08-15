require_relative 'lib/csn_scraper.rb'

class Main
  extend CsnScraper
  query = 'If Lena Park'
  results = download_song(query)
  puts results
end