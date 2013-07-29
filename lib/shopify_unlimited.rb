require "shopify_unlimited/version"
require 'shopify_unlimited/active_resource/base_extensions'
require 'shopify_unlimited/active_resource/connection_extensions'

module ShopifyUnlimited
  SHOPIFY_CREDIT_LIMIT_PERIOD = 5.minutes

  class << self
    attr_accessor :use_memcached
    def memcached
      return nil unless use_memcached
      @memcached ||= Dalli::Client.new()
    end

    def cache_key
      URI.parse(ShopifyAPI::Base.site.to_s).host + "_api_reset_time"
    end

    def cached_time(max)
      time = Time.now
      time = memcached.cas(cache_key, 500) do |cached_time|
        return time if cached_time.nil?
        ((time - cached_time) > max) ? time : cached_time
      end
      time
    end

    def set_cached_time(time)
      memcached.set(cache_key, time, 500)
    end
  end
end