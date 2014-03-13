# this allows multiple concurrent workers to behave well, almost
# never triggering a 429, and distributing requests fairly evenly,
# rather than 1 worker hogging the bulk
# of requests until finished, which will typically happen with
# any naive, non-stochastic implementation.


module ShopifyAPI
  class Shop
    def throttle
      @throttle ||= Throttle.new
    end
  end

  class Throttle
    attr_accessor :throttle, :throttle_increment, :requests_threshold
    def initialize
      @throttle = 0.6
      @throttle_increment = @throttle
      @requests_threshold = 10
    end
    
    def run(&block)
      value = nil
      retries ||= 0
      begin
        left = ShopifyAPI.credit_left
        over = @requests_threshold - left
        if over > 0
          @throttle += (over * rand/20) + rand/10
          sleep @throttle + rand/10
        else
          @throttle = (0.94 + rand/20) * @throttle
        end
        t = Time.now
        value = yield
      rescue ActiveResource::ClientError => e
        case e.response.code
        when '404'
          logger.fatal "Shopify returned not found"
          sleep 5 + retries + (rand * rand * 5)
          retries += 1
          if retries < 4
            ActiveResource::Base.logger = Logger.new(STDOUT) 
            retry
          else
            ActiveResource::Base.logger = nil
            raise
          end
        when '429'
          logger.warn "Shopify hit api limit"
          @throttle += rand/5
          retries += 1
          sleep (@throttle * 4 * retries) + rand/10
          if retries < 10
            retry
          else
            raise
          end
        else
          raise
        end
      end
      requests_made = left - ShopifyAPI.credit_left
      if requests_made > 1
        @throttle += (rand/20) * requests_made
        sleep [0, (t + (requests_made * @throttle) - Time.now)].max + rand/10
      else
        @throttle = (0.94 + rand/20) * @throttle
        sleep rand/20
      end
      value
    end
  end
end