#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../unit_test')

# API Accounts Test Suite
class APIAccounts < UnitTests
  AUTH = { username: 'administrator', password: 'password' }.freeze
  BAD_AUTH = { username: 'foo', password: 'bar' }.freeze

  def test_api_accounts
    response = get('/api/accounts')
    assert (response.code == 403), 'Was not Forbidden'

    response = get('/api/accounts', AUTH)
    assert (response.code == 200 && !response.empty?), 'Did not Recieve 200 or there was no data.'
  end

  def test_api_accounts_me
    response = get('/api/accounts/me')
    assert (response.code == 403), 'Was not Forbidden'

    response = get('/api/accounts/me', AUTH)
    assert (response.code == 200 && !response.empty?), 'Did not Recieve 200 or there was no data.'
  end

  def test_api_accounts_id
    accounts = get('/api/accounts', AUTH)
    user_one = accounts[0]

    response = get('/api/accounts/' + user_one['id'])
    assert (response.code == 403), 'Was not Forbidden'

    response = get('/api/accounts/' + user_one['id'], AUTH)
    assert (response.code == 200 && !response.empty?), 'Did not Recieve 200 or there was no data.'

    response = get('/api/accounts/' + user_one['id'], BAD_AUTH)
    assert (response.code == 403), 'Did not Recieve 403.'
  end
end
