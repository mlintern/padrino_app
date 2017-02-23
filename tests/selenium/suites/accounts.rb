#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../watir-selenium')

# Accounts Test Suite
class Accounts < SeleniumTests
  def test_accounts_pages_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    main_nav('Settings', 'Accounts')
    assert @driver.url.include?('/accounts'), 'Did not load Accounts page'

    wac(@driver.a(:css, '.new-user-tab'))
    assert @driver.url.include?('/accounts/new'), 'Did not load new user page'

    wac(@driver.a(:css, '.card-users-tab'))
    assert @driver.url.include?('/accounts/cards'), 'Did not load new user page'

    wac(@driver.a(:css, '.edit-user-tab'))
    assert @driver.url.include?('/accounts/edit'), 'Did not load new user page'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_accounts_pages_negative
    sign_in(NRETNIL_USER_TWO_USERNAME, NRETNIL_USER_TWO_PASSWORD)
    @driver.goto(ENVIRONMENT_URL + '/accounts')
    assert !@driver.url.include?('/accounts'), 'Did load List Accounts page'

    @driver.goto(ENVIRONMENT_URL + '/accounts/new')
    assert !@driver.url.include?('/accounts/new'), 'Did load New Account page'

    @driver.goto(ENVIRONMENT_URL + '/accounts/cards')
    assert !@driver.url.include?('/accounts/cards'), 'Did load Accounts Card page'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end
end
