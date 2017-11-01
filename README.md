# ActiveMerchant::Adyen12

[![Build Status](https://travis-ci.org/3scale/active_merchant-adyen12.svg?branch=master)](https://travis-ci.org/3scale/active_merchant-adyen12)

This gem is to be used with [activemerchant](https://github.com/activemerchant/active_merchant)
It adds another gateway called Adyen12 to use with [Adyen](https://www.adyen.com/) payment solution.
It uses the old V12 API

There is already an integration of Adyen in the official activemerchant gem
However it lacks recurring payment functionality.

## Why not making a Pull Request to the activemerchant repository?

**YES OF COURSE** a pull request there is the way to do it. But because of those reason we do not do it:

- this is just extracted from [https://github.com/3scale/active_merchant/tree/adyen](https://github.com/3scale/active_merchant/tree/adyen)
- we do not have time to make a proper pull request
- we cannot wait for the PR to be merged by them


**Still** we believe that this is the correct thing to do.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_merchant-adyen12'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_merchant-adyen12


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/3scale/active_merchant-adyen12. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveMerchant::Adyen12 project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/3scale/active_merchant-adyen12/blob/master/CODE_OF_CONDUCT.md).
