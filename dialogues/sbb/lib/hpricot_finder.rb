require 'rubygems'
require 'hpricot'
require 'mechanize'
require 'sbb_finder'

class HpricotFinder < SbbFinder
  
  def self.find(from, to, datetime)
    # res = saved_response(from, to, datetime)
    res = saved_mechanized_response(from, to, datetime)
    
    doc = Hpricot(res.body)
    # find time tags and scan for times
    # TODO if dauer is bigger than 9:59 -> problems, but switzerland isn't that big
    times = (doc/"tr[@class^='zebra-row']>td.result[@headers='time']").to_s.scan(/\d{2}:\d{2}/)
   
    # if no times found, re-get
    # if times.size == 0
    #   puts 'reget'
    #   res = saved_response(from, to, datetime)
    #   doc = Hpricot(res.body)
    #   # find time tags and scan for times
    #   # TODO if dauer is bigger than 9:59 -> problems, but switzerland isn't that big
    #   times = (doc/"tr[@class^='zebra-row']>td.result[@headers='time']").to_s.scan(/\d{2}:\d{2}/)
    # end
   
   puts times.inspect
   
    # add in_groups_of to array instance
    # TODO move
    class << times
      def in_groups_of(number, fill_with = nil, &block)
        require 'enumerator'
        collection = dup
        collection << fill_with until collection.size.modulo(number).zero? unless fill_with == false
          grouped_collection = [] unless block_given?
          collection.each_slice(number) do |group|
          block_given? ? yield(group) : grouped_collection << group
        end
        grouped_collection unless block_given?
      end
    end
    # prepare array of hashes
    times.in_groups_of(2).map { |a| { :departure => a[0], :arrival => a[1] } }
  end
  
  def self.mechanized_response(from, to, datetime)
    agent = WWW::Mechanize.new
    page = agent.get('http://fahrplan.sbb.ch/bin/query.exe/dn?externalCall=yes')
    # puts "page: #{page.pretty_inspect}"
    form = page.forms[0]
    # puts "form: #{form.pretty_inspect}"
    form.fields.find {|f| f.name == 'REQ0JourneyStopsS0G'}.value = from
    form.fields.find {|f| f.name == 'REQ0JourneyStopsZ0G'}.value = to
    form.fields.find {|f| f.name == 'REQ0JourneyDate'}.value = sbb_date(datetime)
    form.fields.find {|f| f.name == 'REQ0JourneyTime'}.value = sbb_time(datetime)
    button = form.buttons.find {|b| b.value =~ /suchen/}
    # puts "button: #{button.pretty_inspect}"
    page = agent.submit(form, button)
    
    # while loop reget :)
    # reget if form fields contain empty fields
    from_field = form.fields.find {|f| f.name == 'REQ0JourneyStopsS0A'}
    to_field = form.fields.find {|f| f.name == 'REQ0JourneyStopsZ0G'}
    # check if one empty
    if (!from_field.nil? and from_field.value.empty?) or (!to_field.nil? and to_field.value.empty?)
      from_field.value = from
      to_field.value = to
      button = form.buttons.find {|b| b.value =~ /suchen/}
      # reget
      puts 'reget'
      page = agent.submit(form, button)
    end
    
    # click on spätere Verbindungen a few times to get cached
    # puts "links #{page.links.pretty_inspect}"
    1.times do
      puts 'getting more results'
      # Spätere Verbindungen »
      # link_later = page.links.find { |l| l.text =~ /Sp&#228;tere Verbindungen&nbsp;&#xBB;/ }
      # p page.links
      link_later = page.links.find { |l| l.text =~ /Spätere Verbindungen/ }
      page = agent.click(link_later)
    end
    
    # puts "body: #{page.body}"
    page
  end
  
  def self.saved_mechanized_response(from, to, datetime)
    res = mechanized_response(from, to, datetime)
    save_response_in_file(res)
    res    
  end
  
end