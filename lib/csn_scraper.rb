require 'net/http'
require 'nokogiri'
require 'colorize'

module CsnScraper
  class CsnQueryHelper
    ##
    # Uses the search subdomain of chiasenhac.com to query results
    # 
    # @param query (string): [title] [artist]
    # If title/artist has multiple words then words should be seperated 
    # spaces; title and artist should be seperated by a space
    #
    # i.e. ChiaSeNhacDownloader.query_html_page("21 guns green day")
    def self.query_first_result(query)
      base_url = 'search.chiasenhac.vn'
      search_prefix = '/search.php?s='
      raise 'Must pass in string' if query.class != String
      query.downcase!.gsub!(' ', '+')
      puts "url: #{base_url + search_prefix + query}"
      html = Net::HTTP.get(base_url, search_prefix + query)
      mp3_link = Nokogiri::HTML(html).xpath('//a[@class="musictitle"]').slice(0..0).map do |link|
        link['href']
      end
      return mp3_link.first
    end
  end

  ##
  # Get link to download from mp3 link
  # Checks if 320 kbps is available then tries 128 kbps
  #
  # @param mp3_link: URL formatted as a string
  #
  def download_song(query)
    mp3_link = CsnQueryHelper.query_first_result(query)
    puts "link: #{mp3_link}"
    begin
      resp = Net::HTTP.get_response(URI.parse(mp3_link))
      html = Net::HTTP.get(URI.parse(mp3_link))
      mp3_link = resp['location']
    end while resp.is_a?(Net::HTTPRedirection)
    puts resp.to_s.green
    download_links = Nokogiri::HTML(html).xpath('//a[@class="download_item"]')
    download_links.class
  end
end