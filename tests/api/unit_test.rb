#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require 'erb'
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/retry'
require 'httparty'
require './env' if File.exist?('env.rb')

# Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
# Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new(:color => true)]
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]
Minitest::Retry.use!(
  retry_count: 1, # The number of times to retry. The default is 3.
  verbose: true, # Whether or not to display the message at the time of retry. The default is true.
  io: $stdout # Display destination of retry when the message. The default is stdout.
)

# UnitTests Class
class UnitTests < Minitest::Test
  ADMIN_AUTH = { username: ENV['NRETNIL_ADMIN_USERNAME'], password: ENV['NRETNIL_ADMIN_PASSWORD'] }.freeze
  USER_ONE_AUTH = { username: ENV['NRETNIL_USER_ONE_USERNAME'], password: ENV['NRETNIL_USER_ONE_PASSWORD'] }.freeze
  USER_TWO_AUTH = { username: ENV['NRETNIL_USER_TWO_USERNAME'], password: ENV['NRETNIL_USER_TWO_PASSWORD'] }.freeze
  BAD_AUTH = { username: 'foo', password: 'bar' }.freeze

  def setup
    @server = 'http://localhost:3000'
  end

  def get(url, auth = nil)
    HTTParty.get(@server + url, basic_auth: auth)
  end

  def post(url, data = {}, auth = nil)
    HTTParty.post(@server + url, body: data.to_json, basic_auth: auth)
  end

  def teardown; end
end
