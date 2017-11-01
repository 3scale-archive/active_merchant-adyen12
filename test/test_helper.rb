require 'bundler'

Bundler.require :development, :test

spec = Gem::Specification.find_by_name('activemerchant')

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.join(spec.gem_dir, 'test')

require 'active_merchant/adyen12'

module ActiveMerchant
  module Fixtures
    DEFAULT_CREDENTIALS = File.join(File.dirname(__FILE__), 'fixtures.yml') unless defined?(DEFAULT_CREDENTIALS)
  end
end

require File.join(spec.gem_dir, 'test', 'test_helper.rb')
