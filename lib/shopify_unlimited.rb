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
      now = Time.now
      result = now
      return result unless memcached
      unless memcached.add(cache_key, now, 500)
        memcached.cas(cache_key, 500) do |cached_time|
          result = ((now - cached_time) > max) ? now : cached_time
          result
        end 
      end
      result
    end

    def set_cached_time(time)
      return unless memcached
      memcached.set(cache_key, time, 500)
    end  


    def estimated_time_until_reset
      credit_record = ShopifyAPI::Base.connection.shopify_credit
      time = credit_record.time unless credit_record.nil?
      time ||= cached_time(ShopifyUnlimited::SHOPIFY_CREDIT_LIMIT_PERIOD)
      est = ShopifyUnlimited::SHOPIFY_CREDIT_LIMIT_PERIOD - (Time.now - time)
      [est, 0].max
    end
  end
end