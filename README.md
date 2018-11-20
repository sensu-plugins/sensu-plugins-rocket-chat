## Sensu-Plugins-RocketChat

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-rocket-chat.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-rocket-chat)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-rocket-chat.svg)](http://badge.fury.io/rb/sensu-plugins-rocket-chat)

## Functionality

This plugin provides a handler to send notifications to a RocketChat chat.

## Files
 * bin/handler-rocketchat.rb

## Usage

After installation, you have to set up a `pipe` type handler, like so:

```json
{
  "handlers": {
    "rocketchat": {
      "type": "pipe",
      "command": "handler-rocketchat.rb",
      "filter": "occurrences"
    }
  }
}
```

This gem also expects a JSON configuration file with the following contents:

```json
{
  "rocketchat": {
    "server_url": "SERVER_URL",
    "username": "YOUR_USERNAME",
    "password": "YOUR_PASSWORD",
    "room_id": "ROOM_ID",
    "error_file_location": "/tmp/rocketchat_handler_error"
  }
}
```

### Parameters:
- `server_url`: The URL of the RocketChat instance (e.g.
  `https://chat.yourcompany.com`).
- `ssl_ca_file` (optional): The path to the certificate file used by the
  RocketChat server.
- `ssl_verify_mode` (optional): Value `1` will try to verify the SSL certificate
  of the RocketChat server (default), while `0` will skip verification (not
  recommended).
- `username`: The username of the RocketChat account that will be used to send
  the messages. You probably want to use a special "bot" account for this.
- `password`: The password of the RocketChat account that will be used to send
  the messages.
- `room_id`: The room to which the error message is to be sent. To send the
  message to a user, `room_id` should look like `@username`. For a channel,
  `channel-name`.
- `error_file_location` (optional): in case there is a failure sending the
  message to RocketChat (ie. connectivity issues), the exception message will
  be written to a file in this location. You can then monitor this
  location to detect any errors with the RocketChat handler.
- `message_template` (optional): An ERB template in Markdown to use to format
  messages instead of the default. Supports the following variables:
  - `action_name`
  - `action_icon`
  - `client_name`
  - `check_name`
  - `status`
  - `status_icon`
  - `output`
- `message_template_file` (optional): A file to read an ERB template in Markdown
  from to format messages. Supports the same variables as `message_template`.


### Advanced configuration

By default, the handler assumes that the config parameters are specified in the
`rocketchat` top-level key of the JSON, as shown above. You also have the option
to make the handler fetch the config from a different key. To do this, pass the
`-j` option to the handler with the name of the desired key You can define
multiple handlers, and each handler can send notifications to a different room
and from a different bot. You could, for example, have critical and non-critical
RocketChat rooms, and send the notifications to one or the other depending on the
check. For example:

```json
{
  "handlers": {
    "critical_rocketchat": {
      "type": "pipe",
      "command": "handler-rocketchat.rb -j critical_rocketchat_options"
    },
    "non_critical_rocketchat": {
      "type": "pipe",
      "command": "handler-rocketchat.rb -j non_critical_rocketchat_options"
    }
  }
}
```

This example will fetch the options from a JSON like this:

```json
{
  "rocketchat": {
    "server_url": "SERVER_URL",
    "username": "YOUR_USERNAME",
    "password": "YOUR_PASSWORD"
  },
  "critical_rocketchat_options": {
    "room_id": "emergency-alerts"
  },
  "non_critical_rocketchat_options": {
    "room_id": "non-critical-alerts"
  }
}
```

As you can see, you can specify the default config in the `rocketchat` key, and
the rest of the config in their own custom keys.

You can also directly add the configuration parameters to the event data using a
mutator. For example:

```ruby
#!/usr/bin/env ruby
require 'rubygems'
require 'json'
event = JSON.parse(STDIN.read, symbolize_names: true)
event.merge!(room_id: 'emergency-alerts')
puts JSON.dump(event)
```

### Configuration precedence

The handler will load the config as follows (from least to most priority):

* Default `rocketchat` key
* Custom config keys
* Event data

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
