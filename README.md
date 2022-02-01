[![Ruby](https://github.com/mpodwysocki/azure-notificationhubs-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/mpodwysocki/azure-notificationhubs-ruby/actions/workflows/main.yml)

# Azure Notification Hubs SDK for Ruby (unofficial)

This is the unofficial Azure Notification Hubs SDK for Ruby, bringing the power of Azure Notification Hubs to the Ruby language.  This is an ongoing effort to

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'azure-notificationhubs'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install azure-notificationhubs
```

## Usage

```ruby
CONNECTION_STRING = "<AccessPolicy-ConnectionString>"
HUB_NAME = "<Hub-Name>"

notification_hub = Azure::NotificationHubs::NotifcationHub.new(CONNECTION_STRING, HUB_NAME)

JSON_BODY = '{ "aps" : { "alert" : "Hello" } }'
DEVICE_TOKEN = "00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0"
PLATFORM_TYPE = "apple"
CONTENT_TYPE = "application/json;charset=utf-8"

headers = { "apns-topic" => "com.microsoft.Example", "apns-priority" => "10", "apns-push-type" => "alert" }

notification = Azure::NotificationHubs::Notification.new(JSON_BODY, headers, CONTENT_TYPE, PLATFORM_TYPE)
response = notification_hub.send_direct_notification(notification, DEVICE_TOKEN)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/azure-notificationhubs-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/azure-notificationhubs-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Azure::Notificationhubs::Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/azure-notificationhubs-ruby/blob/main/CODE_OF_CONDUCT.md).
