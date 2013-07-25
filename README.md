# ShopifyUnlimited

1. Allows API calls like products = Product.find(:all, params:{limit: false}), which will make as many requests as needed to fetch all Products in batches of 250. The result set can be queried for the number of requests required: ```products.requests_made```
2. 
2. Attempts to record api limits a little better by adding ```ShopifyAPI::Base.connection.shopify_credit```. This object contains the credit used since the first request (in a given process) and the time of the first request. It resets when the credit used goes down or the time elapsed has been more than 5 minutes.

## Installation

Add this line to your application's Gemfile:

    gem 'shopify_unlimited'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shopify_unlimited

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
