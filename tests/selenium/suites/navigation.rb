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

  def test_user_menu_negative
    sign_in(NRETNIL_USER_TWO_USERNAME, NRETNIL_USER_TWO_PASSWORD)
    @driver.goto(ENVIRONMENT_URL + '/accounts')
    wait_till_page_loads
    assert !@driver.url.include?('/accounts'), 'Loaded accounts page when it should not have'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_main_menu_negative
    sign_in(NRETNIL_USER_TWO_USERNAME, NRETNIL_USER_TWO_PASSWORD)
    @driver.goto(ENVIRONMENT_URL + '/curl')
    wait_till_page_loads
    assert !@driver.url.include?('/curl'), 'Loaded curl page when it should not have'

    @driver.goto(ENVIRONMENT_URL + '/translator')
    wait_till_page_loads
    assert !@driver.url.include?('/translator'), 'Loaded translator page when it should not have'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_todo_menu
    sign_in(NRETNIL_USER_ONE_USERNAME, NRETNIL_USER_ONE_PASSWORD)
    wac(@driver.a(:css, '.todo-btn'))
    @driver.div(:css, '.modal.fade.in')
    assert @driver.div(:css, '.modal-header').exists?, 'Modal did not Load'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end
end
