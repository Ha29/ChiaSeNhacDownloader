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
#       begin
#   link = 'https://beta.chiasenhac.vn/mp3/us-uk/us-pop/run-to-you~whitney-houston~ts3wdd76q9mmtk.html'
#   HTTParty.get(link)
# rescue OpenSSL::SSL::SSLError => error
#   puts "change to http"
#   base_link = link.split('https://')[1]
#   link = 'http://' + base_link
#   HTTParty.get(link) 
# end
      html = Net::HTTP.get(URI.parse(mp3_link))
      mp3_link = resp['location']
    end while resp.is_a?(Net::HTTPRedirection)
    puts resp.to_s.green
    download_links = Nokogiri::HTML(html).xpath('//a[@class="download_item"]')
    link = download_links[0]['href']
    link_sections = link.split('/')
    link_sections.each_with_index { |r, i|
      puts "#{i}: #{r}"
    }
    quality_320 = link_sections.dup
    quality_320[-2] = "320"
    link = quality_320.join('/')
    uri = URI.parse(link)
    puts "downloading ..."
    response = Net::HTTP.get_response(uri)
    puts "writing ..."
    Dir.mkdir('downloads/') unless File.exists?('downloads/')
    File.open('downloads/test.mp3', 'w+') { |file| file.write(response.body)} if response.is_a?(Net::HTTPSuccess)
    puts "finished!"
  end

  ##
  #
  #

end