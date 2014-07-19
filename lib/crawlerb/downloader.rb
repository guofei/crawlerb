require 'mechanize'

module Crawlerb

  class Downloader
    def initialize
      @agent = Mechanize.new
      @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def download(url)
      @url = url
      page = @agent.get url
      push_links page
      page.body
    end

    private

    def push_links(page)
      page.links.each { |link| push_link link }
      page.iframes.each { |link| push_link link }
    end

    def push_link(link)
      begin
        return unless link_check link
      rescue => e
        STDERR.puts e
        return
      end

      scheduler = Scheduler.instance
      begin
        scheduler.push resolve_uri(link).to_s if URI(@url).host == resolve_uri(link).host
      rescue => e
        STDERR.puts e
      end
    end

    def link_check(link)
      if self.class.method_defined? :url_exclude
        url_exclude.each do |str|
          return false if resolve_uri(link).to_s.downcase.include? str
        end
      end
      if self.class.method_defined? :url_include
        url_include.each do |str|
          return false unless resolve_uri(link).to_s.downcase.include? str
        end
      end
      return true;
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
