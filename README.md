# Drowsy [![Build Status](https://travis-ci.org/samandmoore/drowsy.svg?branch=master)](https://travis-ci.org/samandmoore/drowsy)

# Under construction

An ActiveRecord-y library for interacting with RESTful web
APIs. Heavily inspired by [Her](https://github.com/remiprev/her), [Spyke](https://github.com/balvig/spyke), and [ActiveResource](https://github.com/rails/activeresource).

At its core, Drowsy is just ActiveModel-powered plain old Ruby objects and
[Faraday](https://github.com/lostisland/faraday).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'drowsy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install drowsy

## Usage

TODO: Write usage instructions here

### Working with an API

* expected response format
* included json middleware
* creating a Faraday connection
* interacting with multiple APIs

### API-side validations

TODO: talk about how these work

### Custom requsts

TODO: talk about Drowsy::Http#request

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/samandmoore/drowsy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sleepy project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/samandmoore/drowsy/blob/master/CODE_OF_CONDUCT.md).
