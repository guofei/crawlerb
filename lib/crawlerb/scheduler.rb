require 'set'
require 'singleton'
require 'uri'

require "redis"

module Crawlerb

  class Scheduler
    include Singleton
    def initialize
      @redis = Redis.new(:host => "127.0.0.1", :port => 6379, :db => 15)
    end

    # get next url
    def pop
      @redis.spop "url"
    end

    def started?
      @redis.scard("url") > 0
    end

    # push domain to scheduler
    def push(url)
      return unless check_url url
      return if @redis.sismember "history", url

      @redis.sadd "history", url
      @redis.sadd "url", url
    end

    private
    def check_url(url)
      url =~ /\A#{URI::regexp(['http', 'https'])}\z/
    end
  end

end
