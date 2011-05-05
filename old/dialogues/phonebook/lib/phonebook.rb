require 'rubygems'
require 'mechanize'

class Phonebook
  
  def self.find(number)
    res = mechanized_response(number)

    doc = Hpricot(res.body)
    name = (doc/"div.rname h4 a")[0].inner_html
    puts name
    address = (doc/"div.raddr")[0].inner_html
    puts address

    # just return the first find
    [name, address]
  end
  
  def self.mechanized_response(number)
    agent = WWW::Mechanize.new
    page = agent.get("http://tel.search.ch/#{number}")
    # puts "page: #{page.pretty_inspect}"
    
    # puts "body: #{page.body}"
    page
  end
  
end