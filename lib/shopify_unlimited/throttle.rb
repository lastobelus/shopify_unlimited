# this allows multiple concurrent workers to behave well, almost
# never triggering a 429, and distributing requests fairly evenly,
# rather than 1 worker hogging the bulk
# of requests until finished, which will typically happen with
# any naive, non-stochastic implementation.

module ShopifyUnlimited
  class Throttle
    attr_accessor :throttle, :throttle_increment, :requests_threshold, :running
    def initialize
      @throttle = 0.6
      @throttle_increment = @throttle
      @requests_threshold = 10
      @debug = ! ENV['SHOPIFY_UNLIMITED_DEBUG'].blank?
    end
    
    def dbg(msg)
      puts msg if @debug
    end
    
    def run
      if @running
        return yield
      end
      @running = true
      value = nil
      retries ||= 0
      orig_logger = ActiveResource::Base.logger
      begin
        dbg "--- throttle.run ---"
        left = ShopifyAPI::Base.connection.response.nil? ? @requests_threshold : ShopifyAPI.credit_left
        over = @requests_threshold - left
        dbg "left: #{left} over: #{over}"
        if over > 0
          @throttle += (over * rand/20) + rand/10
          dbg "  sleep #{@throttle + rand/10}"
          sleep @throttle + rand/10
        else
          @throttle = (0.94 + rand/20) * @throttle
        end
        t = Time.now
        dbg "  yield"
        value = yield
      rescue ActiveResource::ClientError => e
        case e.response.code
        when '404'
          dbg "  404"
          sleep 5 + retries + (rand * rand * 5)
          retries += 1
          if retries < 2
            ActiveResource::Base.logger ||= Logger.new(STDOUT)
            ActiveResource::Base.logger.info "Shopify returned not found: #{e.message}. Retrying"
            retry
          else
            ActiveResource::Base.logger = orig_logger
            raise
          end
        when '429'
          dbg "  429"
          ActiveResource::Base.logger.info "Shopify hit api limit" if ActiveResource::Base.logger
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
        dbg "  #{requests_made} requests_made"
        @throttle += (rand/20) * requests_made
        fuzzy_sleep_time = [0, (t + (requests_made * @throttle) - Time.now)].max + rand/10
        dbg "  sleep #{fuzzy_sleep_time}"
        sleep fuzzy_sleep_time
      else
        @throttle = (0.94 + rand/20) * @throttle
        dbg "  sleep #{rand/20}"
        sleep rand/20
      end
      dbg "=== throttle.done ==="
      value
    ensure
      @running = false
    end
  end
end