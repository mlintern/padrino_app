#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../unit_test')

# API Translator Test Suite
class APITranslator < UnitTests
  def test_api_translator
    response = get('/api/translator', ADMIN_AUTH)
    assert (response.code == 200 && response['success'] && !response['info'].empty?), 'Was not a successful response'

    response = get('/api/translator', USER_ONE_AUTH)
    assert (response.code == 200 && response['success'] && !response['info'].empty?), 'Was not a successful response'
  end

  def test_api_translator_netgative
    response = get('/api/translator')
    assert (response.code == 403 && !response['success']), 'Was not Forbidden'

    response = get('/api/translator', USER_TWO_AUTH)
    assert (response.code == 403 && !response['success']), 'Was not Forbidden'
  end

  def test_api_translator_install
    response = post('/api/translator/install')
    assert (response.code == 400 && !response['success']), 'App Installed when it should not have'
  end
end
