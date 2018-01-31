#!/bin/env ruby
# frozen_string_literal: true

# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'active_support/core_ext/string'
require 'date'
require 'json'
require 'compendium-api'
require 'nretnil-password'
require 'nretnil-fake-data'
require 'nretnil-translate'
require 'nretnil-utilities'
require 'securerandom'
require './env' if File.exist?('env.rb')
Bundler.require(:default, RACK_ENV)

# Load worker definitions
require File.join(PADRINO_ROOT, 'config', 'workers.rb')

##
# ## Enable devel logging
#
log_level = ENV['LOG_LEVEL'].to_sym unless ENV['LOG_LEVEL'].nil?
Padrino::Logger::Config[:production] = { log_level: log_level || :info, stream: :to_file, log_static: true }
Padrino::Logger::Config[:development] = { log_level: log_level || :debug, stream: :stdout }
#
# ## Configure your I18n
#
# I18n.default_locale = :en
# I18n.enforce_available_locales = false
#
# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
  # Sidekiq should log to our main log file.
  Sidekiq.logger = Padrino.logger

  Sidekiq.configure_client do |config|
    config.redis = { size: 5 } # Limit the client size, see http://manuel.manuelles.nl/blog/2012/11/13/sidekiq-on-heroku-with-redistogo-nano/
  end
  Sidekiq.configure_server do |config|
    config.redis = { size: 55 } # Limit the server size, see http://manuel.manuelles.nl/blog/2012/11/13/sidekiq-on-heroku-with-redistogo-nano/
  end
  DataMapper.finalize
end

Padrino.load!
