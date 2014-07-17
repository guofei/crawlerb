require 'mechanize'
require 'nokogiri'

module Crawlerb
  module Rule
    def self.included(spider)
      spider.extend ClassMethods
    end

    module ClassMethods
      def url_exclude(*strs)
        define_method :url_exclude do
          strs
        end
      end

      def url_include(*strs)
        define_method :url_include do
          strs
        end
      end

      def start_url(url)
        define_method :start_url do
          url
        end
      end
    end
  end

  class Spider
    include Rule

    def crawl
      Scheduler.instance.push start_url

      agent = Mechanize.new
      agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
      loop do
        url = Scheduler.instance.pop
        STDERR.puts url
        return if url.nil?
        begin
          page = agent.get url
          page.links.each { |link| push_link link }
          page.iframes.each { |link| push_link link }
        rescue => e
          STDERR.puts e
          next
        end
        str = page.body
        parse str, url
      end
    end

    def pase(doc, url)
      raise 'Called abstract method !!'
    end

    private
    def push_link(link)
      begin
        link_check link
      rescue => e
        STDERR.puts e
        return
      end

      scheduler = Scheduler.instance
      begin
        scheduler.push resolve_uri(link).to_s if URI(start_url).host == resolve_uri(link).host
      rescue => e
        STDERR.puts e
      end
    end

    def link_check(link)
      if self.class.method_defined? :url_exclude
        url_exclude.each do |str|
          return if resolve_uri(link).to_s.downcase.include? str
        end
      end
      if self.class.method_defined? :url_include
        url_include.each do |str|
          return unless resolve_uri(link).to_s.downcase.include? format
        end
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
