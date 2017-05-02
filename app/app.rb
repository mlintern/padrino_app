#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

module PadrinoApp
  # App
  class App < Padrino::Application
    register Padrino::Mailer
    register Padrino::Helpers
    register Sinatra::Flash

    ##
    # Application configuration options
    #
    # set :raise_errors, true         # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true          # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true      # Shows a stack trace in browser (default for development)
    set :logging, true                # Logging in STDOUT for development and file for production (default only for development)
    set :public_folder, 'public'      # Location for static assets (default root/public)
    # set :reload, false              # Reload application files (default in development)
    # set :default_builder, "foo"     # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"         # Set path for I18n translations (default your_app/locales)
    # disable :sessions               # Disabled sessions by default (enable if needed)
    # disable :flash                  # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout              # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    # Padrino Mailer setup
    set :delivery_method, smtp: {
      address: 'smtp.gmail.com',
      port: 587,
      user_name: ENV['GMAIL_EMAIL'],
      password: ENV['GMAIL_PASSWORD'],
      authentication: :plain,
      enable_starttls_auto: true
    }

    enable :sessions

    ##
    # Caching support.
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
    # set :cache, Padrino::Cache::Store::Memory.new(50)
    # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #

    ## or
    #
    # error(401) { @title = "Error 401"; render('errors/401', :layout => :error) }
    # error(403) { @title = "Error 403"; render('errors/403', :layout => :error) }
    # error(404) { @title = "Error 404"; render('errors/404', :layout => :error) }
    # error(500) { @title = 'Error 500', render('errors/500', layout: :error) }
  end
end
