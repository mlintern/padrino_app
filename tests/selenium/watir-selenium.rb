#!/bin/env ruby
# encoding: utf-8

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
require './env' if File.exists?('env.rb')

puts ENVIRONMENT_URL = ENV['TARGET_URL'] || 'https://app.nretnil.com'
puts ENVIRONMENT_BROWSER = ENV["BROWSER"] || 'chrome'
ROOT_DIR = File.expand_path(File.dirname(__FILE__))
SCREENSHOT_DIR = ROOT_DIR + '/screenshots'

NRETNIL_USERNAME = ENV["NRETNIL_USERNAME"]
NRETNIL_PASSWORD = ENV["NRETNIL_PASSWORD"]
NRETNIL_KEY = ENV["NRETNIL_KEY"]

# Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
# Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new(:color => true)]
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(:color => true)]
Minitest::Retry.use!(
  retry_count: 1,  # The number of times to retry. The default is 3.
  verbose: true,   # Whether or not to display the message at the time of retry. The default is true.
  io: $stdout     # Display destination of retry when the message. The default is stdout.
)

class ApplicationTests < Minitest::Test

  include Selenium

  def setup

    begin
      timout = ENV['TIMEOUT'] || 30 # 30 seconds is default
      Watir.default_timeout = timout.to_i

      case ENVIRONMENT_BROWSER
        when "firefox"
          @driver = Watir::Browser.start ENVIRONMENT_URL, :firefox
        when "chrome"
          @driver = Watir::Browser.start ENVIRONMENT_URL, :chrome, :switches => %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate]
        else
          puts "\n\n\nI don't know this BROWSER"
          abort
        end
      @date = DateTime.now.strftime("%Y-%m-%d~%H:%M:%S")

      if ENV['BROWSER'] != 'safari'
        @driver.window.resize_to(1024, 768)
      end

    rescue StandardError => e
      puts "StandardError"
      puts "@driver was not created."
      raise
    end
  end

  def screenshot (name)
    time = Time.new
    @driver.screenshot.save 'screenshots/' + name + '_' + time.strftime('%Y%m%d_%H%M%S') + '.png'  # @driver.driver.save_screenshot('screenshots/' + name + '_' + time.strftime('%Y%m%d_%H%M%S') + '.png')
  end

  def get_error (test_name, error = nil)
    puts error.message
    puts error.backtrace
    screenshot(test_name)
    raise
  end

  def wait_till_page_loads ()
    @driver.body(:css, '.nretnil-document-ready').wait_until_present
  end

  def sign_in (username, password)
    @driver.goto ENVIRONMENT_URL
    @driver.text_field(:id, "username").set(username)
    @driver.text_field(:id, "password").set(password)
    @driver.button(:css, '.sign-in-btn').click
    wait_till_page_loads
  end

  def sign_out
    wait_till_page_loads
    @driver.a(:css, '.user-menu-dropdown').wait_until_present
    @driver.a(:css, '.user-menu-dropdown').click
    @driver.a(:css, '.logout-btn').wait_until_present
    @driver.a(:css, '.logout-btn').click
    wait_till_page_loads
  end

  def teardown
    @driver.quit
  end
end