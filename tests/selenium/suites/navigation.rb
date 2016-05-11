#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../watir-selenium')

# Navigation Test Suite
class Navigation < SeleniumTests
  def test_main_menu_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    main_nav('Home')
    assert @driver.div(:css, '.api-enpoints').exists?, 'Did not load Home page'
    main_nav('PL Translator')
    assert @driver.url.include?('/translator'), 'Did not load PL Translator page'
    main_nav('Curl API Tool')
    assert @driver.url.include?('/curl'), 'Did not load Curl API Tool page'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_user_menu_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    user_nav('Accounts')
    assert @driver.url.include?('/accounts'), 'Did not load Accounts page'
    user_nav('Profile Settings')
    assert @driver.url.include?('/accounts/edit/'), 'Did not load Profiled Settings page'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end
end
