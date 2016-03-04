# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'date'
require 'json'
require 'compendium-api'
require 'nretnil-password'
require 'nretnil-fake-data'
require 'securerandom'
require './env' if File.exists?('env.rb')
Bundler.require(:default, RACK_ENV)

##
# ## Enable devel logging
#
log_level = ENV['LOG_LEVEL'].to_sym unless ENV['LOG_LEVEL'].nil?
Padrino::Logger::Config[:production] = { :log_level => log_level || :info, :stream => :to_file, :log_static => true }
Padrino::Logger::Config[:development] = { :log_level => log_level || :debug, :stream => :stdout }
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
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
  DataMapper.finalize
end

Padrino.load!
