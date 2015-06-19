require 'mechanize'

module Crawlerb
  class Downloader
    def initialize(rule)
      @agent = Mechanize.new
      @agent.max_history = 1
      @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @rule = rule
    end

    def download(url, &block)
      @url = url
      @page = @agent.get url
      @page.body
    end

    def each_link(&block)
      @page.links.each do |link|
        if check(link)
          block.call resolve_uri(link).to_s
        end
      end

      @page.iframes.each do |link|
        if check(link)
          block.call resolve_uri(link).to_s
        end
      end
    end

    private

    def check(link)
      begin
        return false if link.href.nil? || link.href.to_s.include?("javascript:")
        @rule[:exclude].each do |str|
          return false if resolve_uri(link).to_s.downcase.include? str
        end

        if same_host?(link)
          return true
        else
          return false
        end
      rescue => e
        return false
      end
    end

    def same_host?(url)
      URI(@url).host == resolve_uri(url).host
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
