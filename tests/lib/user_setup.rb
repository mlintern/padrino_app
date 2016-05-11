#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# This script will make sure that all of the correct users exist and have the correct permissions
# user - user, curl
# user2 - user
# admin - admin, curl, translate

if Account.first(username: '__selenium_user_one')
  Account.update(password: 'password', password_confirmation: 'password', role: %w(user curl))
else
  Account.create(username: '__selenium_user_one', email: 'michael.weston@nretnil.com', name: 'Selenium', surname: 'User One', password: 'password', password_confirmation: 'password', role: %w(user curl), last_update: DateTime.now.utc, id: SecureRandom.uuid)
end

if Account.first(username: '__selenium_user_two')
  Account.update(password: 'password', password_confirmation: 'password', role: %w(user))
else
  Account.create(username: '__selenium_user_two', email: 'michael.weston@nretnil.com', name: 'Selenium', surname: 'User Two', password: 'password', password_confirmation: 'password', role: %w(user), last_update: DateTime.now.utc, id: SecureRandom.uuid)
end

if Account.first(username: '__selenium_admin')
  Account.update(password: 'password', password_confirmation: 'password', role: %w(admin curl translate))
else
  Account.create(username: '__selenium_admin', email: 'michael.weston@nretnil.com', name: 'Selenium', surname: 'Admin', password: 'password', password_confirmation: 'password', role: %w(admin curl translate), last_update: DateTime.now.utc, id: SecureRandom.uuid)
end
