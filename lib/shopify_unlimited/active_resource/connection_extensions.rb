module ShopifyUnlimited
  module ThrottledConnection
    def throttle
      @throttle ||= ShopifyUnlimited::Throttle.new
    end
    def with_auth
      throttle.run do
        super
      end
    end
  end
end

module ActiveResource
  class Connection
    prepend ShopifyUnlimited::ThrottledConnection
  end
end

