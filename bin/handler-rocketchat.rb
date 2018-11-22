#!/usr/bin/env ruby
# frozen_string_literal: true

#
#   handler-rocketchat
#
# DESCRIPTION:
#   This handler sends messages to a given RocketChat room (user or channel).
#
# OUTPUT:
#   Plain text
#
# PLATFORMS:
#   Linux, BSD, Windows, OS X
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rocketchat
#
# USAGE:
#   This gem requires a JSON configuration file with the following contents:
#     {
#       "rocketchat": {
#         "server_url": "SERVER_URL"
#         "username": "YOUR_USERNAME",
#         "password": "YOUR_PASSWORD",
#         "room_id": "ROOM_ID",
#         "error_file_location": "/tmp/rocketchat_handler_error"
#       }
#     }
#   For more details, please see the README.
#
# NOTES:
#
# LICENSE:
#
#   Copyright 2018 Hernan Schmidt <hschmidt@suse.de>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-handler'
require 'rocketchat'
require 'cgi'
require 'erb'

class RocketChatHandler < Sensu::Handler
  option :json_config,
         description: 'Config name',
         short: '-j config_key',
         long: '--json_config config_key',
         required: false

  def handle
    print 'Sending to RocketChat: ' + params.inspect

    rocket_server = RocketChat::Server.new(server_url, server_settings)
    session = rocket_server.login(username, password)
    session.chat.post_message(room_id: room_id,
                              text: build_message)
    session.logout

    puts '... done.'
    clear_error
  rescue StandardError => e
    handle_error(e)
    puts "... RocketChat handler error '#{e.inspect}' while attempting to report an incident: #{event_name} #{action_name}"
  end

  def room_id
    fetch_setting 'room_id'
  end

  def username
    fetch_setting 'username'
  end

  def password
    fetch_setting 'password'
  end

  def error_file
    fetch_setting 'error_file_location'
  end

  def server_url
    fetch_setting 'server_url'
  end

  def ssl_ca_file
    fetch_setting('ssl_ca_file')
  end

  def ssl_verify_mode
    fetch_setting('ssl_verify_mode')
  end

  def server_settings
    settings = {}
    settings[:ssl_ca_file] = ssl_ca_file if ssl_ca_file
    settings[:ssl_verify_mode] = ssl_verify_mode if ssl_verify_mode
    settings
  end

  def fetch_setting(setting_key)
    config_key = config[:json_config]

    value = @event[setting_key]
    value ||= settings[config_key][setting_key] if config_key
    value || settings['rocketchat'][setting_key]
  end

  def event_name
    client_name + '/' + check_name
  end

  def action_name
    actions = {
      'create' => 'Created',
      'resolve' => 'Resolved',
      'flapping' => 'Flapping'
    }
    actions[@event['action']]
  end

  def action_icon
    icons = {
      'create' => "\xF0\x9F\x98\xB1",
      'resolve' => "\xF0\x9F\x98\x8D",
      'flapping' => "\xF0\x9F\x90\x9D"
    }
    icons[@event['action']]
  end

  def client_name
    @event['client']['name']
  end

  def check_name
    @event['check']['name']
  end

  def output
    @event['check']['output'].strip
  end

  def build_message
    template_file = fetch_setting 'message_template_file'
    if !template_file.nil?
      template = File.read(template_file)
    else
      template = fetch_setting 'message_template'
      template ||= default_message
    end

    message = ERB.new(template).result(binding)

    message
  end

  def default_message
    [
      '**Alert <%= action_name %>** <%= action_icon %>',
      '**Host:** <%= client_name %>',
      '**Check:** <%= check_name %>',
      '**Status:** <%= status %> <%= status_icon %>',
      '**Output:** <%= output %>'
    ].join("\n")
  end

  def params
    {
      server_url: server_url,
      server_settings: server_settings,
      room_id: room_id,
      text: build_message
    }
  end

  def handle_error(exception)
    return unless error_file

    File.open(error_file, 'w') do |f|
      f.puts 'Params: ' + params.inspect
      f.puts 'Exception: ' + exception.inspect
    end
  end

  def clear_error
    File.delete(error_file) if error_file && File.exist?(error_file)
  end

  def check_status
    @event['check']['status']
  end

  def status
    status = {
      0 => 'OK',
      1 => 'Warning',
      2 => 'Critical',
      3 => 'Unknown'
    }
    status[check_status.to_i]
  end

  def status_icon
    icons = {
      0 => "\xF0\x9F\x91\x8D",
      1 => "\xE2\x9A\xA1",
      2 => "\xF0\x9F\x9A\xA8",
      3 => "\xF0\x9F\x8C\x80"
    }
    icons[check_status.to_i]
  end
end
