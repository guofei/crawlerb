require 'byebug'
require 'mechanize'
require 'nokogiri'

module Crawlerb

  class Spider
    def self.exclude(*formats)
      define_method :exclude do
        formats
      end
    end

    def self.start_url(url)
      define_method :start_url do
        url
      end
    end

    def crawl
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
          p e
          next
        end
        str = page.body
        parse str, url
      end
    end

    def pase(doc, url)
      raise 'Called abstract method !!'
    end

    def start_url
      raise 'Called abstract method !!'
    end

    private
    def push_link(link)
      if self.class.method_defined? :exclude
        exclude.each do |format|
          begin
            return if resolve_uri(link).to_s.downcase.include? format
          rescue => e
            p e
            return
          end
        end
      end

      scheduler = Scheduler.instance
      begin
        scheduler.push resolve_uri(link).to_s if URI(start_url).host == resolve_uri(link).host
      rescue => e
        p e
      end
    end

    def resolve_uri(link)
      if link.uri.host.nil?
        link.resolved_uri
      else
        link.uri
      end
    end
  end

end
