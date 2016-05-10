#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../unit_test')

# String Class Additions
class String
  def uuid?
    !match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/).nil?
  end

  def sym?
    !match(/[^a-zA-Z0-9]/).nil?
  end
end

# API Test Suite
class API < UnitTests
  def test_api
    response = get('/api')
    assert (response.code == 200 && response['success']), 'success was not returned'
  end

  def test_api_info
    response = get('/api/info')
    assert (response.code == 200 && response['success']), 'success was not returned'
  end

  def test_api_password
    # No Params
    response = get('/api/password')
    assert (response.code == 200 && response['password'] && response['password'].length == 15 && response['phonetic'] && response['password'].sym?), 'Password was not returned correctly.'

    # Length Param
    response = get('/api/password?length=20')
    assert (response.code == 200 && response['password'].length == 20 && response['password'].sym?), 'Password was not 20 characters long.'

    # Symbols Param is false
    response = get('/api/password?symbols=false')
    assert (response.code == 200 && !response['password'].sym? && response['password'].length == 15), 'Password contains Symbols.'

    # Symbols Param is false and Length Param
    response = get('/api/password?symbols=false&length=25')
    assert (response.code == 200 && !response['password'].sym? && response['password'].length == 25), 'Password contains Symbols or was not 25 characters long.'
  end

  def test_api_password_phrase
    response = get('/api/password/phrase')
    assert (response.code == 200 && response['password'] && response['phonetic']), 'password not provided'
  end

  def test_api_uuid
    response = get('/api/uuid')
    assert (response.code == 200 && response.uuid?), 'Response is not a uuid'
  end

  def test_external_pub
    response = get('/api/external_pub')
    assert (response.code == 200), 'Response not 200'

    response = post('/api/external_pub')
    assert (response.code == 400), 'Response not 400'

    data = { content: {} }

    response = post('/api/external_pub', data)
    assert (response.code == 400), 'Response not 400'

    data = { content: { title: 'Unit Test' } }

    response = post('/api/external_pub', data)
    assert (response.code == 202 && !response['id'].nil? && !response['url'].nil?), 'Response not 202'
  end

  def test_external_pub_debug
    response = post('/api/external_pub/debug')
    assert (response.code == 400 && !response['data_received'].nil?), 'Response not 400 or data_received not present'

    data = { content: {} }

    response = post('/api/external_pub/debug', data)
    assert (response.code == 400 && !response['data_received'].nil?), 'Response not 400 or data_received not present'

    data = { content: { title: 'Unit Test' } }

    response = post('/api/external_pub/debug', data)
    assert (response.code == 202 && !response['id'].nil? && !response['url'].nil? && !response['data_received'].nil?), 'Response not 202 or id, url or data_received missing'
  end

  def test_get_fakedata
    response = get('/api/fakedata')
    assert (response.code == 200 && response.length == 10 && response[0].length == 7), 'Response not 200 or there are not 10 data entries or there are not 7 elements per entry'

    response = get('/api/fakedata?count=25')
    assert (response.code == 200 && response.length == 25), 'Response not 200 or there are not 25 data entries'

    response = get('/api/fakedata?count=15&name=fullname&id=uuid&dob=date')
    assert (response.code == 200 && response.length == 15 && response[0].length == 3), 'Response not 200 or there are not 15 data entries or the entry does not have 3 elements'
  end

  def test_post_fakedata
    response = post('/api/fakedata', message: 'hi')
    assert (response.code == 200 && !response['message'].nil?), 'Response not 200, or message not present'
  end
end
