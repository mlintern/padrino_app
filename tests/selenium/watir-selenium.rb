#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'erb'
require 'bundler/setup'
require 'selenium-webdriver'
require 'watir-webdriver'
require 'watir-webdriver/wait'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/retry'
require 'date'
require 'net/smtp'
require 'compendium-api'
require 'nretnil-fake-data'
require 'nretnil-password'
require File.expand_path(File.dirname(__FILE__) + '/selenium_helpers.rb')
require './env' if File.exist?('env.rb')

puts ENVIRONMENT_URL = ENV['TARGET_URL'] || 'http://app.nretnil.com'
puts ENVIRONMENT_BROWSER = ENV['BROWSER'] || 'chrome'
ROOT_DIR = File.expand_path(File.dirname(__FILE__))
SCREENSHOT_DIR = ROOT_DIR + '/screenshots'

NRETNIL_ADMIN_USERNAME = ENV['NRETNIL_ADMIN_USERNAME']
NRETNIL_ADMIN_PASSWORD = ENV['NRETNIL_ADMIN_PASSWORD']
NRETNIL_USER_ONE_USERNAME = ENV['NRETNIL_USER_ONE_USERNAME']
NRETNIL_USER_ONE_PASSWORD = ENV['NRETNIL_USER_ONE_PASSWORD']
NRETNIL_USER_TWO_USERNAME = ENV['NRETNIL_USER_TWO_USERNAME']
NRETNIL_USER_TWO_PASSWORD = ENV['NRETNIL_USER_TWO_PASSWORD']

# Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
# Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new(:color => true)]
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]
Minitest::Retry.use!(
  retry_count: 1,  # The number of times to retry. The default is 3.
  verbose: true,   # Whether or not to display the message at the time of retry. The default is true.
  io: $stdout # Display destination of retry when the message. The default is stdout.
)

# Selenium Test Class
class SeleniumTests < Minitest::Test
  include Selenium

  def setup
    timout = ENV['TIMEOUT'] || 30 # 30 seconds is default
    Watir.default_timeout = timout.to_i

    case ENVIRONMENT_BROWSER
    when 'firefox'
      @driver = Watir::Browser.start ENVIRONMENT_URL, :firefox
    when 'chrome'
      @driver = Watir::Browser.start ENVIRONMENT_URL, :chrome, switches: %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate]
    else
      puts "\n\n\nI don't know this BROWSER"
      abort
    end
    @date = DateTime.now.strftime('%Y-%m-%d~%H:%M:%S')

    # @driver.window.maximize unless ENV['BROWSER'] == 'safari'
  rescue StandardError
    puts 'StandardError'
    puts '@driver was not created.'
    raise
  end

  def teardown
    @driver.quit
  end
end
