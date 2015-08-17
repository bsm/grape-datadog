grape-datadog
=============

Datadog stats reporter for [Grape][0], based on code from [this Librato
gem][1], which is based on [this NewRelic gem][2], using [dogstatsd-ruby][3]

## Installation

Add this line to your application's Gemfile:

    gem 'grape-datadog'

Or install:

    $ gem install grape-datadog

Include it in your Grape API like this:

    class TestAPI < Grape::API
      use Grape::Datadog::Middleware

      get 'hello' do
        "Hello World"
      end
    end

For full configuration options, please see the [Documentation][4].

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make a pull request

[0]: https://github.com/intridea/grape
[1]: https://github.com/seanmoon/grape-librato
[2]: https://github.com/flyerhzm/newrelic-grape
[3]: https://github.com/DataDog/dogstatsd-ruby
[4]: http://www.rubydoc.info/gems/grape-datadog
