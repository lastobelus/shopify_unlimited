module ShopifyAPI
  module Limits
    class Error < StandardError
    end
  end
end

puts "patching activeresource from shopify_unlimited"
module ActiveResource
  class Base     
    SHOPIFY_API_MAX_LIMIT = 500
    
    class << self
      # get reference to unbound class-method #find_every
      find_every = self.instance_method(:find_every)

      define_method(:find_every) do |options|
        options[:params] ||= {}
        
        # Determine number of ShopifyAPI requests to stitch together all records of this query.
        limit = options[:params][:limit]
        

        # Bail out to default functionality unless limit == false
        return find_every.bind(self).call(options) unless limit == false
        
        # ShopifyAPI started returning 404 if you leave this in
        options[:params].update(:limit => SHOPIFY_API_MAX_LIMIT)

        results  = []
        limit = SHOPIFY_API_MAX_LIMIT
        last_count = 0 - limit
        page = 0
        # as long as the number of results we got back is not less than the limit we (probably) have more to fetch
        while( (results.count - last_count) >= limit) do
          raise ShopifyAPI::Limits::Error.new if ShopifyAPI.credit_maxed?
          page +=1
          last_count = results.count
          options[:params][:page] = page
          results.concat find_every.bind(self).call(options)
        end
        results                  
      end
    end      
  end
end