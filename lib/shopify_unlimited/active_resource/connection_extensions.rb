module ::ShopifyUnlimited
  class CreditUsed
    SHOPIFY_CREDIT_LIMIT_PERIOD = 5.minutes

    attr_accessor :time, :used
    def initialize(used)
      @time = Time.now
      @used = used
    end

    def stale?(used)
      (@used > used) || ((Time.now - @time) > SHOPIFY_CREDIT_LIMIT_PERIOD)
    end

    def estimated_time_until_reset
      est = SHOPIFY_CREDIT_LIMIT_PERIOD - (Time.now - @time)
      [est, 0].max
    end

  end
end

module ::ActiveResource
  class Connection
    SHOPIFY_CREDIT_LIMIT_HEADER_PARAM = 'http_x_shopify_shop_api_call_limit'

    attr_reader :shopify_credit
    def handle_response_with_response_time_capture(response)
      handle_response_without_response_time_capture(response)
      if(shopify_credit_header = response[SHOPIFY_CREDIT_LIMIT_HEADER_PARAM])
        used = shopify_credit_header.split('/').shift.to_i

        if @shopify_credit.nil? || @shopify_credit.stale?(used)
          @shopify_credit = ::ShopifyUnlimited::CreditUsed.new(used)
        else
          @shopify_credit.used = used
        end
      end
      response
    end
    alias_method_chain :handle_response, :response_time_capture
  end
end
