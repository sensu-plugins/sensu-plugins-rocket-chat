# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'

require_relative 'lib/sensu-plugins-rocketchat'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.authors = [
    'Hernan Schmidt',
    'Sensu-Plugins and contributors'
  ]

  s.date                   = Date.today.to_s
  s.description            = 'Sensu plugin for interfacing with RocketChat'
  s.email                  = [
    'hschmidt@suse.de',
    'sensu-users@googlegroups.com'
  ]
  s.executables            = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md CHANGELOG.md]
  s.homepage               = 'https://github.com/lagartoflojo/sensu-plugins-rocket-chat'
  s.license                = 'MIT'
  s.metadata               = { 'maintainer' => 'lagartoflojo',
                               'development_status' => 'active',
                               'production_status' => 'unstable - testing recommended',
                               'release_draft' => 'false',
                               'release_prerelease' => 'false' }
  s.name                   = 'sensu-plugins-rocket-chat'
  s.platform               = Gem::Platform::RUBY
  s.post_install_message   = 'You can use the embedded Ruby by setting EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths          = ['lib']
  s.required_ruby_version  = '>= 2.3.0'
  s.summary                = 'Sensu handler for RocketChat'
  s.test_files             = s.files.grep(%r{^(test|spec|features)/})
  s.version                = SensuPluginsRocketChat::Version::VER_STRING

  s.add_runtime_dependency 'rocketchat', '~> 0.1.16'
  s.add_runtime_dependency 'sensu-plugin', '~> 2.7'

  s.add_development_dependency 'bundler',                   '~> 2.0'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  s.add_development_dependency 'github-markup',             '~> 3.0'
  s.add_development_dependency 'pry',                       '~> 0.10'
  s.add_development_dependency 'rake',                      '~> 12.3'
  s.add_development_dependency 'redcarpet',                 '~> 3.2'
  s.add_development_dependency 'rspec',                     '~> 3.4'
  s.add_development_dependency 'rubocop',                   '~> 0.60.0'
  s.add_development_dependency 'yard',                      '~> 0.9.11'
end
# rubocop:enable Metrics/BlockLength
