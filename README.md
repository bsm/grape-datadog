grape-datadog
=============

Datadog intrumentation for [Grape](https://github.com/intridea/grape), integrated via [ActiveSupport::Notifications](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html).

## Installation

Add this line to your application's Gemfile:

    gem 'grape-datadog'

Or install:

    $ gem install grape-datadog

Configure it in an initializer:

    Grape::Datadog.install! do |c|
      c.hostname = "my-host"
      c.tags = ["my:tag"]
    end

For full configuration options, please see the [Documentation][http://www.rubydoc.info/gems/grape-datadog].

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make a pull request

