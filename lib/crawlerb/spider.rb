require 'byebug'
require 'mechanize'
require 'nokogiri'

class Spider
  def Crawl
    Scheduler.instance.push start_url

    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    loop do
      url = Scheduler.instance.pop
      begin
        page = agent.get url
        page.links.each { |link| push_link link }
        page.iframes.each { |link| push_link link }
      rescue => e
        next
      end
      str = page.body
      pase str
    end
  end

  def pase(doc)
    raise 'Called abstract method !!'
  end

  def start_url
    raise 'Called abstract method !!'
  end

  private
  def push_link(link)
    scheduler = Scheduler.instance
    begin
      if link.uri.host.nil?
        scheduler.push link.resolved_uri.to_s
      else
        scheduler.push link.href if link.uri.host == uri.host
      end
    rescue => e
    end
  end
end
