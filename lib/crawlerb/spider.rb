require 'byebug'
require 'mechanize'
require 'nokogiri'

class Spider
  def self.exclude(*formats)
    define_method :exclude do
      formats
    end
  end

  def Crawl
    Scheduler.instance.push start_url

    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    loop do
      url = Scheduler.instance.pop
      return if url.nil?
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
    if self.class.method_defined? :exclude
      exclude.each do |format|
        return if link.href.downcase.include? format
      end
    end

    scheduler = Scheduler.instance
    begin
      if link.uri.host.nil?
        scheduler.push link.resolved_uri.to_s
      else
        scheduler.push link.uri.to_s if link.uri.host == URI(start_url).host
      end
    rescue => e
      p e
    end
  end
end
