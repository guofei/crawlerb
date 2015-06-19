module Crawlerb
  module Rule
    def rule
      url_include_a = []
      url_exclude_a = []
      url_include_a = url_include if self.class.method_defined? :url_include
      url_exclude_a = url_exclude if self.class.method_defined? :url_exclude
      {include: url_include_a, exclude: url_exclude_a}
    end

    def parse?(url)
      return true if rule[:include].length == 0
      rule[:include].each do |s|
        return true if url.to_s.include? s
      end
      return false
    end

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
      downloader = Downloader.new(rule)

      loop do
        url = Scheduler.instance.pop
        STDERR.puts url
        return if url.nil?

        begin
          body = downloader.download url
          parse body, url if parse? url
          downloader.each_link do |link|
            Scheduler.instance.push link
          end
        rescue => e
          STDERR.puts "parse error"
          STDERR.puts e
        end
      end
    end

    def pase(body, url)
      raise 'Called abstract method !!'
    end
  end
end
