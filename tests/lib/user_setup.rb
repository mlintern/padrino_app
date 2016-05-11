#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# This script will make sure that all of the correct users exist and have the correct permissions
# user1 - user, curl
# user2 - translate
# admin - admin, curl, translate

require './env' if File.exist?('env.rb')

users = [{ username: ENV['NRETNIL_ADMIN_USERNAME'], password: ENV['NRETNIL_ADMIN_PASSWORD'] }, { username: ENV['NRETNIL_USER_ONE_USERNAME'], password: ENV['NRETNIL_USER_ONE_PASSWORD'] }, { username: ENV['NRETNIL_USER_TWO_USERNAME'], password: ENV['NRETNIL_USER_TWO_PASSWORD'] }]

account = Account.first(username: users[0][:username])
if account
  account.update(password: users[0][:password], password_confirmation: users[0][:password], role: %w(admin curl translate), last_update: DateTime.now.utc, email: users[0][:username] + '@nretnil.com')
else
  Account.create(username: users[0][:username], email: users[0][:username] + '@nretnil.com', name: 'Selenium', surname: 'Admin', password: users[0][:password], password_confirmation: users[0][:password], role: %w(admin curl translate), last_update: DateTime.now.utc, id: SecureRandom.uuid)
end

account = Account.first(username: users[1][:username])
if account
  account.update(password: users[1][:password], password_confirmation: users[1][:password], role: %w(user curl translate), last_update: DateTime.now.utc, email: users[1][:username] + '@nretnil.com')
else
  Account.create(username: users[1][:username], email: users[1][:username] + '@nretnil.com', name: 'Selenium', surname: 'User One', password: users[1][:password], password_confirmation: users[1][:password], role: %w(user curl translate), last_update: DateTime.now.utc, id: SecureRandom.uuid)
end

account = Account.first(username: users[2][:username])
if account
  account.update(password: users[2][:password], password_confirmation: users[2][:password], role: '', last_update: DateTime.now.utc, email: users[2][:username] + '@nretnil.com')
else
  Account.create(username: users[2][:username], email: users[2][:username] + '@nretnil.com', name: 'Selenium', surname: 'User Two', password: users[2][:password], password_confirmation: users[2][:password], role: '', last_update: DateTime.now.utc, id: SecureRandom.uuid)
end
