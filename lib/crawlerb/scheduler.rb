require 'set'
require 'singleton'
require 'uri'

module Crawlerb

  class Scheduler
    include Singleton

    # get next url
    def pop
      @urls.pop
    end

    # push domain to scheduler
    def push(url)
      @urls ||= []
      @history ||= Set.new
      unless @history.include? url
        @history.add url if check_url(url)
        @urls.push url if check_url(url)
      end
    end

    private
    def check_url(url)
      url =~ /\A#{URI::regexp(['http', 'https'])}\z/
    end
  end

end
