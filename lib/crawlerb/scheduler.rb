require 'uri'
require 'singleton'
require 'redis'

module Crawlerb
  class Scheduler
    include Singleton
    KEY_URL = "url"
    KEY_HISTORY = "history"

    def redis
      #@redis ||= Redis.current
      @redis ||= Redis.new(:host => "127.0.0.1", :port => 6379, :db => 15)
    end

    # get next url
    def pop
      redis.spop KEY_URL
    end

    def started?
      redis.scard(KEY_URL) > 0
    end

    # push domain to scheduler
    def push(url)
      return false unless check_url url
      return false if redis.sismember KEY_HISTORY, url

      redis.multi do
        redis.sadd KEY_HISTORY, url
        redis.sadd KEY_URL, url
      end
      true
    end

    private
    def check_url(url)
      url =~ /\A#{URI::regexp(['http', 'https'])}\z/
    end
  end
end
