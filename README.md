# ShopifyUnlimited

1. Allows API calls like products = Product.find(:all, params:{limit: false}), which will make as many requests as needed to fetch all Products in batches of 250. The result set can be queried for the number of requests required: ```products.requests_made```
2.Contains a throttle tuned for 4-8 workers consuming a single shop's api limit. It will keep all workers busy while limiting the number of refused requests.
3. Retries 404's once. This is because Shopify in the past has occasionally 404'd on count queries.


## Installation

Add this line to your application's Gemfile:

    gem 'shopify_unlimited'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shopify_unlimited


## Usage
1. to fetch all records using behind the scenes batching, use find with limit: false
2. to see the throttle in action, set ENV['SHOPIFY_UNLIMITED_DEBUG'] and it will log info to STDOUT

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
