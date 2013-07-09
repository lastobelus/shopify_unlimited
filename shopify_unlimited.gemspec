# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shopify_unlimited/version'

Gem::Specification.new do |spec|
  spec.name          = "shopify_unlimited"
  spec.version       = ShopifyUnlimited::VERSION
  spec.authors       = ["Michael Johnston"]
  spec.email         = ["lastobelus@mac.com"]
  spec.description   = %q{use limit: false in api requests, & sleep while waiting for limit to reset}
  spec.summary       = %q{use limit: false in api requests, & sleep while waiting for limit to reset}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activeresource', "= 3.2.13"
  spec.add_dependency 'activesupport'
  spec.add_dependency "shopify_api", ">= 3.0.0"
  spec.add_dependency "shopifydev", ">= 0.0.10"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
