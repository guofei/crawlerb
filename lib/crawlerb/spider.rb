require 'mechanize'

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

      downloader = Downloader.new
      loop do
        url = Scheduler.instance.pop
        STDERR.puts url
        return if url.nil?
        begin
          body = downloader.download url
          parse body, url
        rescue => e
          STDERR.puts e
        end
      end
    end

    def pase(body, url)
      raise 'Called abstract method !!'
    end
  end

end
