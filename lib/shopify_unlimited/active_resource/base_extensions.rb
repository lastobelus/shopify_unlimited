module ShopifyAPI
  module Limits
    class Error < StandardError
    end
  end
end


module ActiveResource
  class Base     
    SHOPIFY_MAX_RECORDS_PER_REQUEST = 250
    
    class << self
      # get reference to unbound class-method #find_every
      find_every = self.instance_method(:find_every)

      define_method(:find_every) do |options|
        options[:params] ||= {}
        
        # Determine number of ShopifyAPI requests to stitch together all records of this query.
        limit = options[:params][:limit]
        

        results = []
        results.singleton_class.class_eval do
          attr_accessor :requests_made
        end
        results.requests_made = 0

        # Bail out to default functionality unless limit == false
        # NOTE: the algorithm was switched from doing a count and pre-calculating pages
        # because Shopify 404s on some count requests
        if limit == false          
          options[:params].update(:limit => SHOPIFY_MAX_RECORDS_PER_REQUEST)

          limit = SHOPIFY_MAX_RECORDS_PER_REQUEST
          last_count = 0 - limit
          page = 0
          # as long as the number of results we got back is not less than the limit we (probably) have more to fetch
          while( (results.count - last_count) >= limit) do
            raise ShopifyAPI::Limits::Error.new if ShopifyAPI.credit_maxed?
            page +=1
            last_count = results.count
            options[:params][:page] = page
            results.concat find_every.bind(self).call(options)
            results.requests_made += 1
          end
        else
          results = find_every.bind(self).call(options)
          results.requests_made += 1
        end

        results                  
      end
    end      
  end
end